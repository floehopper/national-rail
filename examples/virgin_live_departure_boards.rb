require "rubygems"
require "bundler/setup"
require "national-rail"

Time.zone = "London"
NationalRail::VirginLiveDepartureBoards.capture_path = File.join(File.dirname(__FILE__), "capture")
boards = NationalRail::VirginLiveDepartureBoards.new
boards.summary("KGX").each do |row|
  puts
  puts "Summary :-"
  p row.attributes
  puts "Will call at :-"
  row.details[:will_call_at].each { |stop| p stop }
  puts "Previous calling points :-"
  row.details[:previous_calling_points].each { |stop| p stop }
end
