require "national_rail"
require "active_support"

Time.zone = "London"
planner = NationalRail::JourneyPlanner.new
summary_rows = planner.plan(
  :from => "London Kings Cross",
  :to => "Edinburgh",
  :time => Time.zone.parse("2010-05-30 10:30")
)
summary_rows.each do |row|
  puts "\nTrain departing at: #{row.departure_time} with #{row.number_of_changes} changes..."
  pp row.details
end
