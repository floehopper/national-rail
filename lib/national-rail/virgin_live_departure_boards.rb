require 'mechanize'
require 'hpricot'
require 'tidy_ffi'

module NationalRail

  class VirginLiveDepartureBoards

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

      def details
        @agent.transact do
          page = @details_link.click
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
      summary_rows = []
      @agent.get("http://realtime.nationalrail.co.uk/virgintrains/summary.aspx?T=#{station_code}") do |page|
        encoding = 'UTF-8'
        summary_rows = (page.doc/"table#TrainTable tbody tr")[2..-1].map do |tr|
          tds = tr/"td"
          details_href = (tds[0]/"a").first["href"]
          details_link = page.links.detect { |l| l.attributes["href"] == details_href }
          SummaryRow.new(@agent, details_link, {
            :from => (tds[0]/"a").inner_text,
            :timetabled_arrival => cell_text(tds[1]),
            :expected_arrival => cell_text(tds[2]),
            :platform => cell_text(tds[3]),
            :to => (tds[4]/"a").inner_text,
            :timetabled_departure => cell_text(tds[5]),
            :expected_departure => cell_text(tds[6]),
            :details_url => "http://realtime.nationalrail.co.uk/virgintrains/#{details_href}"
          })
        end
      end
      summary_rows
    end

  end

end