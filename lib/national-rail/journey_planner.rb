require 'mechanize'
require 'nokogiri'
require 'active_support'
require 'tidy_ffi'

require 'national-rail/journey_planner/details_page_parser'

module NationalRail

  class ParseError < StandardError
    attr_reader :original_exception, :page_html
    def initialize(original_exception, page_html)
      super(original_exception.message)
      @original_exception, @page_html = original_exception, page_html
      set_backtrace(@original_exception.backtrace)
    end
    def inspect
      "#{self.class} wrapping #{@original_exception.inspect}"
    end
  end

  class InputError < StandardError; end

  class JourneyPlanner

    OPERATORS = {
      "Arriva Trains Wales" => "AW",
      "c2c" => "CC",
      "Chiltern Railways" => "CH",
      "CrossCountry" => "XC",
      "East Coast" => "GR",
      "East Midlands Trains" => "EM",
      "First Capital Connect" => "FC",
      "First Great Western" => "GW",
      "First ScotRail" => "SR",
      "Gatwick Express" => "GX",
      "Grand Central Railway" => "GC",
      "Heathrow Connect" => "HC",
      "Heathrow Express" => "HX",
      "Hull Trains" => "HT",
      "Island Line" => "IL",
      "London Midland" => "LM",
      "London Overground" => "LO",
      "London Underground" => "LT",
      "Merseyrail" => "ME",
      "Northern Rail" => "NT",
      "NXEA" => "LE",
      "South West Trains" => "SW",
      "Southeastern" => "SE",
      "Southern" => "SN",
      "Transpennine Express" => "TP",
      "Virgin Trains" => "VT",
      "Wrexham and Shropshire Railway" => "WS"
    }

    class << self
      attr_accessor :capture_path
      def capture(page, filename)
        if capture_path.present?
          FileUtils.mkdir_p(capture_path)
          path = File.join(capture_path, filename)
          File.open(path, "w") { |f| f.write(TidyFFI::Tidy.new(page.parser.to_html).clean) }
        end
      rescue => e
        puts e
      end
    end

    class NokogiriParser < Mechanize::Page
      attr_reader :doc
      def initialize(uri = nil, response = nil, body = nil, code = nil)
        @doc = Nokogiri(TidyFFI::Tidy.new(body).clean)
        super(uri, response, body, code)
      end
    end

    class TimeParser
      def initialize(date)
        @date = date
        @last_time = nil
      end
      def time(hours_and_minutes)
        time = parse(hours_and_minutes)
        if @last_time && (time < @last_time)
          @date += 1
          time = parse(hours_and_minutes)
        end
        @last_time = time
        time
      end
      def parse(hours_and_minutes)
        Time.zone.parse("#{hours_and_minutes} #{@date}")
      end
    end

    class SummaryRow

      attr_reader :departure_time, :number_of_changes

      def initialize(agent, date, departure_time, number_of_changes, link, status)
        @agent, @date = agent, date
        @departure_time, @number_of_changes, @link = departure_time, number_of_changes, link
        @status = status
      end

      def cancelled?
        @status =~ %r{cancelled}i
      end

      def details
        return {} if number_of_changes.to_i > 0
        return {} if cancelled?
        @agent.transact do
          details_page = @link.click
          JourneyPlanner.capture(details_page, "details.html")
          parser = DetailsPageParser.new(details_page.doc, @date)
          begin
            parser.parse
          rescue => e
            JourneyPlanner.capture(details_page, "details-error.html")
            page_html = TidyFFI::Tidy.new(details_page.parser.to_html).clean
            raise ParseError.new(e, page_html)
          end
        end
      end

    end

    def initialize
      Time.zone ||= 'London'
      @agent = Mechanize.new
      @agent.pluggable_parser.html = NokogiriParser
      @agent.user_agent_alias = "Mac FireFox"
    end

    def plan(options = {})
      summary_rows = []
      @agent.get("http://www.nationalrail.co.uk/") do |home_page|
        JourneyPlanner.capture(home_page, "index.html")
        button = nil
        times_page = home_page.form_with(:action => "http://ojp.nationalrail.co.uk/en/s/planjourney/plan") do |form|
          button = form.buttons.last
          form["jpState"] = "single"
          form["commandName"] = "journeyPlannerCommand"
          form["from.searchTerm"] = options[:from]
          form["to.searchTerm"] = options[:to]
          form["timeOfOutwardJourney.arrivalOrDeparture"] = "DEPART"
          form["timeOfOutwardJourney.monthDay"] = options[:time].strftime("%d/%m/%Y")
          form["timeOfOutwardJourney.hour"] = options[:time].strftime("%H")
          form["timeOfOutwardJourney.minute"] = options[:time].strftime("%M")
          # form["timeOfReturnJourney.arrivalOrDeparture"] = "DEPART"
          # form["timeOfReturnJourney.monthDay"] = "Today"
          # form["timeOfReturnJourney.hour"] = "15"
          # form["timeOfReturnJourney.minute"] = "0"
          form["viaMode"] = "VIA"
          form["via.searchTerm"] = ""
          form["offSetOption"] = "0"
          form["reduceTransfers"] = "true"
          form["_reduceTransfers"] = "on" # hidden (duplicate of reduceTransfers?)
          form["operatorMode"] = "SHOW" # alternative is "DONT_SHOW"
          form["operator.code"] = ""
          form["lookForSleeper"] = "true"
          form["_lookForSleeper"] = "on" # hidden (duplicate of lookForSleeper?)
          form["directTrains"] = "true"
          form["_directTrains"] = "on" # hidden (duplicate of directTrains?)
          form["includeOvertakenTrains"] = "true"
          form["_includeOvertakenTrains"] = "on" # hidden (duplicate of includeOvertakenTrains?)
        end.click_button(button)

        JourneyPlanner.capture(times_page, "summary.html")

        if (times_page.doc/".error-message").any?
          raise InputError.new((times_page.doc/".error-message").first.inner_text.gsub(/\s+/, " ").strip)
        end

        year = options[:time].year
        date_as_string = (times_page.doc/".journey-details span").first.children.first.inner_text.gsub(/\s+/, " ").gsub(/\+ 1 day/, '').strip
        date = Date.parse("#{date_as_string} #{year}")

        (times_page.doc/"table#outboundJourneyTable > tbody > tr").reject { |tr| %w(status changes).include?(tr.attributes["class"].value) }.each do |tr|

          if (tr.attributes["class"].value == "day-heading")
            date_as_string = (tr/"th > p > span").first.inner_text.strip
            date = Date.parse("#{date_as_string} #{year}")
            next
          end

          departure_time = TimeParser.new(date).time((tr/"td:nth-child(1)").inner_text.strip)
          number_of_changes = (tr/"td:nth-child(6)").inner_text.strip
          status = (tr/"td:nth-child(10) .status").inner_text.strip

          anchor = (tr/"a[@id^=journeyOption]").first
          next unless anchor

          link = times_page.links.detect { |l| l.attributes["id"] == anchor.attributes["id"].value }

          summary_rows << SummaryRow.new(@agent, date, departure_time, number_of_changes, link, status)
        end
      end
      summary_rows
    rescue => e
      page = @agent.current_page
      JourneyPlanner.capture(page, "summary-error.html")
      page_html = TidyFFI::Tidy.new(page.parser.to_html).clean
      raise ParseError.new(e, page_html)
    end
  end
end