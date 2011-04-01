require File.join(File.dirname(__FILE__), '..', 'test_helper')

class DetailsPageParserTest < Test::Unit::TestCase

  include TimeTestHelper

  def setup
    Time.zone = "London"
  end

  def teardown
    Timecop.return
  end

  def test_sample_1
    Timecop.travel(Time.zone.parse("2010-12-28 13:00"))
    doc = Nokogiri(File.open(File.join(File.dirname(__FILE__), '..', 'fixtures', 'virgin_live_departure_boards', '2010-12-28-1254.22', 'term.aspx?T=NWCSTLE+&J=1355492&R=0')))
    details = NationalRail::VirginLiveDepartureBoards::DetailsPageParser.new(doc).parse

    previous_stations = details[:previous_calling_points].map { |pcp| pcp[:station] }
    assert_equal ["Carlisle", "Haltwhistle", "Haydon Bridge", "Hexham", "Prudhoe", "Metro Centre"], previous_stations

    previous_timetabled_departures = details[:previous_calling_points].map { |pcp| pcp[:timetabled_departure] }
    assert_equal [time_today('11:34'), time_today('12:02'), time_today('12:13'), time_today('12:23'), time_today('12:34'), time_today('12:45')], previous_timetabled_departures

    previous_expected_departures = details[:previous_calling_points].map { |pcp| pcp[:expected_departure] }
    assert_equal [nil, nil, nil, nil, nil, nil], previous_expected_departures

    previous_actual_departures = details[:previous_calling_points].map { |pcp| pcp[:actual_departure] }
    assert_equal ['On time', time_today('12:06'), 'No report', time_today('12:27'), 'No report', time_today('12:50')], previous_actual_departures

    future_stations = details[:will_call_at].map { |wca| wca[:station] }
    assert_equal [], future_stations

    future_timetabled_arrivals = details[:will_call_at].map { |wca| wca[:timetabled_arrival] }
    assert_equal [], future_timetabled_arrivals

    future_expected_arrivals = details[:will_call_at].map { |wca| wca[:expected_arrival] }
    assert_equal [], future_expected_arrivals
  end

  def test_sample_2
    Timecop.travel(Time.zone.parse("2010-12-28 13:00"))
    doc = Nokogiri(File.open(File.join(File.dirname(__FILE__), '..', 'fixtures', 'virgin_live_departure_boards', '2010-12-28-1254.22', 'train.aspx?T=NWCSTLE+&J=1370355&R=0')))
    details = NationalRail::VirginLiveDepartureBoards::DetailsPageParser.new(doc).parse

    previous_stations = details[:previous_calling_points].map { |pcp| pcp[:station] }
    assert_equal ["Inverness", "Aviemore", "Kingussie", "Pitlochry", "Perth", "Gleneagles", "Stirling", "Falkirk Grahamston", "Haymarket", "Edinburgh"], previous_stations

    previous_timetabled_departures = details[:previous_calling_points].map { |pcp| pcp[:timetabled_departure] }
    assert_equal [time_today('07:55'), time_today('08:29'), time_today('08:42'), time_today('09:23'), time_today('09:56'), time_today('10:12'), time_today('10:30'), time_today('10:45'), time_today('11:11'), time_today('11:30')], previous_timetabled_departures

    previous_expected_departures = details[:previous_calling_points].map { |pcp| pcp[:expected_departure] }
    assert_equal [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil], previous_expected_departures

    previous_actual_departures = details[:previous_calling_points].map { |pcp| pcp[:actual_departure] }
    assert_equal ['On time', 'Cancelled', 'Cancelled', 'Cancelled', 'Cancelled', 'Cancelled', 'Cancelled', 'Cancelled', 'Cancelled', 'Cancelled'], previous_actual_departures

    future_stations = details[:will_call_at].map { |wca| wca[:station] }
    assert_equal ["York", "Grantham", "London Kings Cross"], future_stations

    future_timetabled_arrivals = details[:will_call_at].map { |wca| wca[:timetabled_arrival] }
    assert_equal [time_today('13:52'), time_today('14:45'), time_today('15:55')], future_timetabled_arrivals

    future_expected_arrivals = details[:will_call_at].map { |wca| wca[:expected_arrival] }
    assert_equal ['On time', time_today('14:43'), 'On time'], future_expected_arrivals
  end

  def test_sample_3
    Timecop.travel(Time.zone.parse("2010-12-28 13:00"))
    doc = Nokogiri(File.open(File.join(File.dirname(__FILE__), '..', 'fixtures', 'virgin_live_departure_boards', '2010-12-28-1254.22', 'train.aspx?T=NWCSTLE+&J=1355419&R=0')))
    details = NationalRail::VirginLiveDepartureBoards::DetailsPageParser.new(doc).parse
    assert_equal 'On time', details[:will_call_at][0][:expected_arrival]
  end

  def test_sample_4
    Timecop.travel(Time.zone.parse("2010-12-28 13:00"))
    doc = Nokogiri(File.open(File.join(File.dirname(__FILE__), '..', 'fixtures', 'virgin_live_departure_boards', '2011-01-02-1754.09', 'term.aspx?T=KNGX++++&J=1471779&R=0')))
    details = NationalRail::VirginLiveDepartureBoards::DetailsPageParser.new(doc).parse
    assert_equal 'Dunkeld & Birnam', details[:previous_calling_points][7][:station]
  end

  def test_sample_5
    Timecop.travel(Time.zone.parse("2010-12-28 13:00"))
    doc = Nokogiri(File.open(File.join(File.dirname(__FILE__), '..', 'fixtures', 'virgin_live_departure_boards', '2011-01-03-1536.00', 'term.aspx?T=KNGX++++&J=1488545&R=0')))
    details = NationalRail::VirginLiveDepartureBoards::DetailsPageParser.new(doc).parse
    assert_equal 'Delayed', details[:previous_calling_points][0][:actual_departure]
    assert_equal 'Cancelled', details[:previous_calling_points][1][:expected_departure]
  end

  def test_sample_6
    Timecop.travel(Time.zone.parse("2011-02-14 23:46:10"))
    doc = Nokogiri(File.open(File.join(File.dirname(__FILE__), '..', 'fixtures', 'virgin_live_departure_boards', '2011-02-14-2346.10', 'term.aspx?T=KNGX++++&J=57761&R=0')))
    details = NationalRail::VirginLiveDepartureBoards::DetailsPageParser.new(doc).parse
    last_calling_point = details[:previous_calling_points].last
    assert_equal time_today("23:16"), last_calling_point[:timetabled_departure]
    assert_equal time_tomorrow("00:07"), last_calling_point[:expected_departure]
  end

  def test_sample_7
    Timecop.travel(Time.zone.parse("2011-02-15 00:00:05"))
    doc = Nokogiri(File.open(File.join(File.dirname(__FILE__), '..', 'fixtures', 'virgin_live_departure_boards', '2011-02-15-0000.05', 'term.aspx?T=KNGX++++&J=57761&R=0')))
    details = NationalRail::VirginLiveDepartureBoards::DetailsPageParser.new(doc).parse
    last_calling_point = details[:previous_calling_points].last
    assert_equal time_yesterday("23:16"), last_calling_point[:timetabled_departure]
    assert_equal time_today("00:11"), last_calling_point[:expected_departure]
  end

  def test_sample_8
    Timecop.travel(Time.zone.parse("2011-02-15 00:27:30"))
    doc = Nokogiri(File.open(File.join(File.dirname(__FILE__), '..', 'fixtures', 'virgin_live_departure_boards', '2011-02-15-0027.30', 'term.aspx?T=KNGX++++&J=57761&R=0')))
    details = NationalRail::VirginLiveDepartureBoards::DetailsPageParser.new(doc).parse
    last_calling_point = details[:previous_calling_points].last
    assert_equal time_yesterday("23:16"), last_calling_point[:timetabled_departure]
    assert_equal time_today("00:11"), last_calling_point[:actual_departure]
  end

end
