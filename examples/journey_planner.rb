require "rubygems"
require "national-rail"
require "active_support"

Time.zone = "London"
planner = NationalRail::JourneyPlanner.new
summary_rows = planner.plan(
  :from => "Peterborough",
  :to => "London Kings Cross",
  :time => Time.zone.parse("2010-11-08 03:00")
)
summary_rows.each do |row|
  puts "\nTrain departing at: #{row.departure_time} with #{row.number_of_changes} changes..."
  pp row.details
end
