require "rubygems"
require "bundler/setup"
require "national-rail"

stations = NationalRail::StationList.new
stations.each do |name, code, latitude, longitude|
  puts "#{name} (#{code}) @ #{latitude},#{longitude}"
end
