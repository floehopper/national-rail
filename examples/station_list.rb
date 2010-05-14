require "rubygems"
require "national_rail"

stations = NationalRail::StationList.new
stations.each do |name, code|
  puts "#{name} (#{code})"
end
