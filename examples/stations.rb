require "rubygems"
require "national_rail"

stations = NationalRail::Stations.new
stations.each do |name, code|
  puts "#{name} (#{code})"
end
