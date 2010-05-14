require "rubygems"
require "national-rail"

stations = NationalRail::StationList.new
stations.each do |name, code|
  puts "#{name} (#{code})"
end
