module NationalRail
  class JourneyPlanner
    class DetailsPageParser

      def initialize(doc, date)
        @doc, @date = doc, date
      end

      def parse
        details = {}
        description = (@doc/"table#journeyLegDetails tbody tr.lastRow td[@colspan='6'] div").last.inner_text.gsub(/\s+/, " ").strip
        company_matches = /(.*) service from .* to .*/.match(description)
        return details unless company_matches
        details[:company] = company_matches[1].strip
        origins, destinations = (/.* service from (.*) to (.*)/.match(description)[1,2]).map{ |s| s.split(",").map(&:strip) }
        details[:origins], details[:destinations] = origins, destinations
        parser = TimeParser.new(@date)

        origin_code = (@doc/"td.origin abbr").inner_html.strip
        departs_at = (@doc/"td.leaving").inner_html.strip
        details[:initial_stop] = {
          :station_code => origin_code,
          :departs_at => parser.time(departs_at)
        }

        details[:stops] = []
        (@doc/".callingpoints table > tbody > tr").each do |tr|
          if (tr/".calling-points").length > 0
            station_code = (tr/".calling-points > a > abbr").inner_html.strip
            arrives_at = (tr/".arrives").inner_html.strip
            departs_at = (tr/".departs").inner_html.strip
            departs_at = arrives_at if arrives_at.present? && departs_at.blank?
            arrives_at = departs_at if arrives_at.blank? && departs_at.present?
            details[:stops] << {
              :station_code => station_code,
              :arrives_at => parser.time(arrives_at),
              :departs_at => parser.time(departs_at)
            }
          end
        end

        destination_code = (@doc/"td.destination abbr").inner_html.strip
        arrives_at = (@doc/"td.arriving").inner_html.strip
        details[:final_stop] = {
          :station_code => destination_code,
          :arrives_at => parser.time(arrives_at)
        }
        details
      end
    end
  end
end