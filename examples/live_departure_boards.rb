require "rubygems"
require "national_rail"

boards = NationalRail::LiveDepartureBoards.new
summary_rows = boards.summary(:from => "KGX", :to => "EDB")
summary_rows.each do |row|
  puts
  pp row.attributes
  stops = row.details
  stops.each do |stop|
    pp stop
  end
end
