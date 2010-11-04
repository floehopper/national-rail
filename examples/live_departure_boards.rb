require "rubygems"
require "national-rail"

boards = NationalRail::LiveDepartureBoards.new
summary_rows = boards.summary(:type => :departures, :from => "York", :to => "London Kings Cross")
summary_rows.each do |row|
  puts
  p row.attributes
  stops = row.details
  stops.each do |stop|
    p stop
  end
end
