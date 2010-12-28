module NationalRail
  class VirginLiveDepartureBoards
    class DetailsPageParser

      include CellParser

      def initialize(doc)
        @doc = doc
      end

      def parse
        will_call_at = []
        table = @doc/"table[@summary='Will call at']"
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
        table = @doc/"table[@summary='Previous calling points']"
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
end
