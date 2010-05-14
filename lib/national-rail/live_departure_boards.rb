require 'mechanize'
require 'hpricot'

module NationalRail

  class LiveDepartureBoards

    class HpricotParser < Mechanize::Page
      attr_reader :doc
      def initialize(uri = nil, response = nil, body = nil, code = nil)
        @doc = Hpricot(body)
        super(uri, response, body, code)
      end
    end
    
    class SummaryRow
      attr_reader :attributes
      def initialize(agent, attributes)
        @agent, @attributes = agent, attributes
      end
      def [](key)
        @attributes[key]
      end
      def details
        page = nil
        @agent.transact do
          page = @attributes[:details][:link].click
          station = nil
          (page.doc/"table.arrivaltable tbody tr").map do |tr|
            tds = (tr/"td")
            tds.unshift(station) if tds.length < 4
            station = tds[0]
            station_url = (station/"a").first.attributes["href"]
            station_code = /station_query\=(.*)$/.match(station_url)[1]
            deparr = (tds[1]/".deparr").remove
            direction = (deparr.inner_text.strip == "Dep") ? "departure" : "arrival"
            {
              :station => {
                :name => (station/"a").inner_text.strip,
                :url => station_url,
                :code => station_code
              },
              :timetabled => {
                :time => tds[1].inner_text.strip,
                :direction => direction
              },
              :expected => {
                :time => tds[2].inner_text.strip
              },
              :actual => {
                :time => tds[3].inner_text.strip
              }
            }
          end
        end
      rescue => e
        File.open("error.html", "w") { |f| f.write(page.parser.to_html) } if page
        raise e
      end
    end

    def initialize
      @agent = Mechanize.new
      @agent.pluggable_parser.html = HpricotParser
    end

    def summary(options = {})
      summary_url = "http://realtime.nationalrail.co.uk/ldb/sumdep.aspx"
      page = @agent.get(summary_url, "T" => options[:from], "S" => options[:to])
      (page.doc/"table.arrivaltable tbody tr").map do |tr|
        destination = (tr/"td:nth-child(1)")
        destination_url = (destination/"a").first.attributes["href"]
        destination_code = /station_query\=(.*)$/.match(destination_url)[1]
        operator = (tr/"td:nth-child(5)")
        operator_url = (operator/"a").first.attributes["href"]
        operator_code = /atocCode\=(.*)$/.match(operator_url)[1]
        details = (tr/"td:nth-child(6)")
        details_url = (details/"a").first.attributes["href"]
        details_link = page.links.detect { |l| l.attributes["href"] == details_url }
        SummaryRow.new(@agent,
          :destination => {
            :name => destination.inner_text,
            :url => destination_url,
            :code => destination_code
          },
          :platform => (tr/"td:nth-child(2)").inner_text,
          :timetabled_at => (tr/"td:nth-child(3)").inner_text,
          :expected_at => (tr/"td:nth-child(4)").inner_text,
          :operator => {
            :name => operator.inner_text,
            :url => operator_url,
            :code => operator_code
          },
          :details => {
            :url => details_url,
            :link => details_link
          }
        )
      end
    rescue => e
      File.open("error.html", "w") { |f| f.write(@agent.current_page.parser.to_html) }
      raise e
    end

  end

end
