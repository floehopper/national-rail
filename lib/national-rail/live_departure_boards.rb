require "active_support"
require "active_support/core_ext"

module NationalRail

  class LiveDepartureBoards

    class SummaryRow
      attr_reader :attributes
      def initialize(attributes)
        @attributes = attributes
      end
      def [](key)
        @attributes[key]
      end
      def details
        url = "http://ojp.nationalrail.co.uk/en/s/ldbdetailsJson"
        params = { "departing" => "false", "serviceId" => @attributes[:service_id] }
        uri = URI.parse("#{url}?#{params.to_query}")
        response = Net::HTTP.get_response(uri)
        json = ActiveSupport::JSON.decode(response.body)
        json["trains"].map do |row|
          {
            :departs => row[1],
            :station => row[2],
            :status => row[3..4],
            :platform => row[5]
          }
        end
      end
    end

    def summary(options = {})
      departing = case options[:type]
      when :departures
        true
      when :arrivals
        false
      else
        true
      end
      if departing
        liveTrainsFrom, liveTrainsTo = options[:from], options[:to]
        origin_or_destination = :destination
      else
        liveTrainsFrom, liveTrainsTo = options[:to], options[:from]
        origin_or_destination = :origin
      end
      url = "http://ojp.nationalrail.co.uk/en/s/ldb/liveTrainsJson"
      params = { "departing" => departing.to_s, "liveTrainsFrom" => liveTrainsFrom, "liveTrainsTo" => liveTrainsTo }
      uri = URI.parse("#{url}?#{params.to_query}")
      response = Net::HTTP.get_response(uri)
      json = ActiveSupport::JSON.decode(response.body)
      trains = json["trains"].map do |row|
        service_id = CGI.unescape(%r{/en/s/ldbdetails/([^\?]+)}.match(row[5])[1])
        SummaryRow.new(
          :service_id => service_id,
          :due => row[1],
          origin_or_destination => row[2],
          :status => CGI.unescapeHTML(row[3]).split("<br/>").map(&:strip),
          :platform => row[4]
        )
      end
    end

  end

end
