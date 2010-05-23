require 'mechanize'
require 'hpricot'

module NationalRail

  class StationList

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
      @coordinates_vs_code = coordinates_vs_code
    end

    def each
      @agent.get("http://www.nationalrail.co.uk/stations/codes/") do |stations_page|
        (stations_page.doc/"table:nth-child(0) tbody tr").each do |tr|
          name, code = (tr/"td").map { |td| td.inner_text }
          coordinates = @coordinates_vs_code[code]
          latitude = coordinates ? coordinates[:latitude] : nil
          longitude = coordinates ? coordinates[:longitude] : nil
          yield(name, code, latitude, longitude) unless name == "DUMMY TEST"
        end
      end
    end
    
    # http://bbc.blueghost.co.uk/earth/stations_all.kml
    # => http://bbc.blueghost.co.uk/earth/stations.kmz
    # => http://bbc.blueghost.co.uk/earth/stations.kml
    def coordinates_vs_code
      result = {}
      File.open(File.join(File.dirname(__FILE__), "stations.kml")) do |file|
        doc = Hpricot(file)
        (doc/"kml/Document/Folder/Folder/Placemark").each do |placemark|
          if ((placemark/"styleurl") || (placemark/"styleUrl")).inner_text == "#railStation"
            name = (placemark/"name").inner_text
            description = (placemark/"description").inner_text
            code = /summary.aspx\?T\=([A-Z]{3})\"/.match(description)[1]
            longitude, latitude = (placemark/"point/coordinates").inner_text.split(",").map(&:to_f)
            result[code] = { :name => name, :latitude => latitude, :longitude => longitude }
          end
        end
      end
      result["SFA"] = { :name => "Stratford International", :latitude => 51.5445797, :longitude => -0.0097182 }
      result["EBD"] = { :name => "Ebbsfleet International", :latitude => 51.4428002, :longitude => 0.3209516 }
      result
    end

  end

end
