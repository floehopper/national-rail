require 'mechanize'
require 'hpricot'

module NationalRail

  class Stations

    class HpricotParser < Mechanize::Page
      attr_reader :doc
      def initialize(uri = nil, response = nil, body = nil, code = nil)
        @doc = Hpricot(body)
        super(uri, response, body, code)
      end
    end

    def initialize
      @agent = Mechanize.new
      @agent.pluggable_parser.html = HpricotParser
    end

    def each
      @agent.get("http://www.nationalrail.co.uk/stations/codes/") do |stations_page|
        (stations_page.doc/"table:nth-child(0) tbody tr").each do |tr|
          name, code = (tr/"td").map { |td| td.inner_text }
          yield(name, code) unless name == "DUMMY TEST"
        end
      end
    end

  end

end