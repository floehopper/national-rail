require "rubygems"
require "bundler/setup"
require "national-rail"

boards = NationalRail::VirginLiveDepartureBoards.new
boards.summary("DHM").each do |row|
  puts
  puts "Summary :-"
  p row.attributes
  puts "Will call at :-"
  row.details[:will_call_at].each { |stop| p stop }
  puts "Previous calling points :-"
  row.details[:previous_calling_points].each { |stop| p stop }
end
