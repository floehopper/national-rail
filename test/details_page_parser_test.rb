require File.join(File.dirname(__FILE__), 'test_helper')

class DetailsPageParserTest < Test::Unit::TestCase

  def setup
    Time.zone = "London"
  end

  def test_sample
    doc = Nokogiri(File.open(File.join(File.dirname(__FILE__), 'fixtures', 'sample', 'details-3.html')))
    date = Date.parse('2010-12-15')
    details = NationalRail::JourneyPlanner::DetailsPageParser.new(doc, date).parse

    assert_equal ["London Kings Cross"], details[:origins]
    assert_equal Time.zone.parse("2010-12-15 12:00"), details[:initial_stop][:departs_at]
    assert_equal "KGX", details[:initial_stop][:station_code]

    station_codes = details[:stops].map { |s| s[:station_code] }
    assert_equal ["PBO", "YRK", "NCL", "EDB", "HYM", "FKG", "STG", "GLE", "PTH", "PIT", "KIN", "AVM"], station_codes

    arrival_times = details[:stops].map { |s| s[:arrives_at].strftime("%H:%M") }
    assert_equal ["12:46", "13:58", "14:58", "16:27", "16:37", "17:04", "17:19", "17:38", "18:00", "18:29", "19:16", "19:29"], arrival_times

    departure_times = details[:stops].map { |s| s[:departs_at].strftime("%H:%M") }
    assert_equal ["12:47", "14:04", "15:00", "16:33", "16:38", "17:05", "17:20", "17:40", "18:00", "18:33", "19:17", "19:29"], departure_times

    assert_equal ["Inverness"], details[:destinations]
    assert_equal Time.zone.parse("2010-12-15 20:08"), details[:final_stop][:arrives_at]
    assert_equal "INV", details[:final_stop][:station_code]
    assert_equal "East Coast", details[:company]
  end

  def test_cancelled
    doc = Nokogiri(File.open(File.join(File.dirname(__FILE__), 'fixtures', 'cancelled', 'details-1.html')))
    date = Date.parse('2010-12-05')
    details = NationalRail::JourneyPlanner::DetailsPageParser.new(doc, date).parse

    assert_equal({}, details)
  end

  def test_bus
    doc = Nokogiri(File.open(File.join(File.dirname(__FILE__), 'fixtures', 'bus', 'details.html')))
    date = Date.parse('2010-12-13')
    details = NationalRail::JourneyPlanner::DetailsPageParser.new(doc, date).parse

    assert_equal({}, details)
  end

end
