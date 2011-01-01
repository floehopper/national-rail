require 'mechanize'
require 'hpricot'
require 'active_support'
require 'tidy_ffi'

module NationalRail
  class VirginLiveDepartureBoards
    module CellParser
      def cell_text(td)
        td.inner_html.gsub('&nbsp;', '')
      end
    end
    class TimeParser
      def initialize(date = Date.today)
        @date = date
      end
      def parse(value)
        value = value.gsub(%r{&#\d+;}, '').gsub(%r{\*+$}, '')
        return value if ['On time', 'Starts here', 'No report'].include?(value)
        parts = value.scan(%r{\d{2}})
        return nil unless parts.length == 2
        Time.zone.parse("#{@date} #{parts.join(':')}")
      end
    end
  end
end

require 'national-rail/virgin_live_departure_boards/details_page_parser'

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

    class SummaryRow

      attr_reader :attributes

      def initialize(agent, details_link, attributes)
        @agent, @details_link, @attributes = agent, details_link, attributes
      end

      def [](key)
        @attributes[key]
      end

      def details
        @agent.transact do
          time_parser = TimeParser.new
          page = @details_link.click
          VirginLiveDepartureBoards.capture(page, @details_link.href)
          parser = DetailsPageParser.new(page.doc, time_parser)
          parser.parse
        end
      end
    end

    class NokogiriParser < Mechanize::Page
      attr_reader :doc
      def initialize(uri = nil, response = nil, body = nil, code = nil)
        @doc = Nokogiri(TidyFFI::Tidy.new(body).clean)
        super(uri, response, body, code)
      end
    end

    include CellParser

    def initialize
      @agent = Mechanize.new
      @agent.pluggable_parser.html = NokogiriParser
      @agent.user_agent_alias = "Mac FireFox"
    end

    def summary(station_code)
      time_parser = TimeParser.new
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
            :timetabled_arrival => time_parser.parse(cell_text(tds[1])),
            :expected_arrival => time_parser.parse(cell_text(tds[2])),
            :platform => parse_integer(cell_text(tds[3])),
            :to => (tds[4]/"a").inner_text.gsub(/\s+/, ' '),
            :timetabled_departure => time_parser.parse(cell_text(tds[5])),
            :expected_departure => time_parser.parse(cell_text(tds[6])),
            :operator => (tds[7]/"a").inner_text.gsub(/\s+/, ' '),
            :details_url => "http://realtime.nationalrail.co.uk/virgintrains/#{details_href}"
          })
        end
      end
      summary_rows
    end

    private

    def parse_integer(value)
      Integer(value) rescue nil
    end

  end

end