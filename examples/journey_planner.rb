require "rubygems"
require "bundler/setup"
require "national-rail"

Time.zone = "London"
NationalRail::JourneyPlanner.capture_path = File.join(File.dirname(__FILE__), "capture")
planner = NationalRail::JourneyPlanner.new
summary_rows = planner.plan(
  :from => "London Kings Cross",
  :to => "Inverness",
  :time => Time.zone.parse("2010-11-12 08:00")
)
summary_rows.each do |row|
  puts "\nTrain departing at: #{row.departure_time} with #{row.number_of_changes} changes..."
  pp row.details
end
