require 'mechanize'
require 'hpricot'
require 'tidy_ffi'

module NationalRail

  class VirginLiveDepartureBoards

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

    module CellParser
      def cell_text(td)
        td.inner_html.gsub("&nbsp;", "")
      end
    end

    class SummaryRow

      include CellParser

      attr_reader :attributes

      def initialize(agent, details_link, attributes)
        @agent, @details_link, @attributes = agent, details_link, attributes
      end

      def [](key)
        @attributes[key]
      end

      def details
        @agent.transact do
          page = @details_link.click
          VirginLiveDepartureBoards.capture(page, @details_link.href)
          will_call_at = []
          table = page.doc/"table[@summary='Will call at']"
          if table.any?
            (table/"tbody tr").each do |tr|
              tds = tr/"td"
              next unless tds.length == 3
              will_call_at << {
                :station => cell_text(tds[0]),
                :timetabled_arrival => cell_text(tds[1]),
                :expected_arrival => cell_text(tds[2])
              }
            end
          end
          previous_calling_points = []
          table = page.doc/"table[@summary='Previous calling points']"
          if table.any?
            (table/"tbody tr").each do |tr|
              tds = tr/"td"
              next unless tds.length == 4
              previous_calling_points << {
                :station => cell_text(tds[0]),
                :timetabled_departure => cell_text(tds[1]),
                :expected_departure => cell_text(tds[2]),
                :actual_departure => cell_text(tds[3])
              }
            end
          end
          { :will_call_at => will_call_at, :previous_calling_points => previous_calling_points }
        end
      end
    end

    class HpricotParser < Mechanize::Page
      attr_reader :doc
      def initialize(uri = nil, response = nil, body = nil, code = nil)
        @doc = Hpricot(TidyFFI::Tidy.new(body).clean)
        super(uri, response, body, code)
      end
    end

    include CellParser

    def initialize
      @agent = Mechanize.new
      @agent.pluggable_parser.html = HpricotParser
      @agent.user_agent_alias = "Mac FireFox"
    end

    def summary(station_code)
      @date = Date.today
      summary_rows = []
      filename = "summary.aspx?T=#{station_code}"
      @agent.get("http://realtime.nationalrail.co.uk/virgintrains/#{filename}") do |page|
        VirginLiveDepartureBoards.capture(page, filename)
        encoding = 'UTF-8'
        summary_rows = (page.doc/"table#TrainTable tbody tr")[2..-1].map do |tr|
          tds = tr/"td"
          details_href = (tds[0]/"a").first["href"]
          details_link = page.links.detect { |l| l.attributes["href"] == details_href }
          SummaryRow.new(@agent, details_link, {
            :from => (tds[0]/"a").inner_text.gsub(/\s+/, ' '),
            :timetabled_arrival => parse_time(cell_text(tds[1])),
            :expected_arrival => parse_time(cell_text(tds[2])),
            :platform => cell_text(tds[3]),
            :to => (tds[4]/"a").inner_text.gsub(/\s+/, ' '),
            :timetabled_departure => parse_time(cell_text(tds[5])),
            :expected_departure => parse_time(cell_text(tds[6])),
            :details_url => "http://realtime.nationalrail.co.uk/virgintrains/#{details_href}"
          })
        end
      end
      summary_rows
    end

    private

    def parse_time(hhmm)
      Time.zone.parse("#{@date} #{hhmm.scan(%r{\d{2}}).join(':')}")
    end

  end

end