require "rubygems"
require "bundler/setup"
require "national-rail"

Time.zone = "London"
planner = NationalRail::JourneyPlanner.new
summary_rows = planner.plan(
  :from => "Peterborough",
  :to => "London Kings Cross",
  :time => Time.zone.parse(Date.tomorrow.to_s)
)
summary_rows.each do |row|
  puts "\nTrain departing at: #{row.departure_time} with #{row.number_of_changes} changes..."
  pp row.details
end
