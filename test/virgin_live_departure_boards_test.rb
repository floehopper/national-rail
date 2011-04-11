require File.join(File.dirname(__FILE__), 'test_helper')

class VirginLiveDepartureBoardsTest < Test::Unit::TestCase

  include TimeTestHelper

  def setup
    Time.zone = "London"
    @boards = NationalRail::VirginLiveDepartureBoards.new
  end

  def teardown
    Timecop.return
  end

  def test_parsing
    stub_request(:get, "realtime.nationalrail.co.uk/virgintrains/summary.aspx?T=NCL").to_return(html_body("fixtures/virgin_live_departure_boards/2010-12-28-1254.22/summary.aspx?T=NCL"))
    Timecop.travel(Time.zone.parse("2010-12-28 12:54:22"))
    rows = @boards.summary("NCL")

    assert_equal 'Bristol Temple Meads', rows[0][:from]
    assert_equal time_today('12:36'), rows[0][:timetabled_arrival]
    assert_equal time_today('12:51'), rows[0][:expected_arrival]
    assert_equal 2, rows[0][:platform]
    assert_equal 'Edinburgh', rows[0][:to]
    assert_equal time_today('12:40'), rows[0][:timetabled_departure]
    assert_equal time_today('12:53'), rows[0][:expected_departure]
    assert_equal 'Cross Country', rows[0][:operator]
    assert_equal 'http://realtime.nationalrail.co.uk/virgintrains/train.aspx?T=NWCSTLE+&J=1371985&R=0', rows[0][:details_url]

    assert_equal 'London Kings Cross', rows[1][:from]
    assert_equal time_today('12:55'), rows[1][:timetabled_arrival]
    assert_equal time_today('12:58'), rows[1][:expected_arrival]
    assert_equal 2, rows[1][:platform]
    assert_equal 'Edinburgh', rows[1][:to]
    assert_equal time_today('12:57'), rows[1][:timetabled_departure]
    assert_equal time_today('12:58'), rows[1][:expected_departure]
    assert_equal 'East Coast', rows[1][:operator]
    assert_equal 'http://realtime.nationalrail.co.uk/virgintrains/train.aspx?T=NWCSTLE+&J=1364614&R=0', rows[1][:details_url]

    assert_equal 'On time', rows[2][:expected_departure]

    assert_equal 'On time', rows[3][:expected_arrival]
    assert_nil rows[3][:timetabled_departure]
    assert_nil rows[3][:expected_departure]

    assert_equal 'On time', rows[4][:expected_departure]

    assert_nil rows[8][:timetabled_arrival]
    assert_nil rows[8][:expected_arrival]

    assert_equal 'Starts here', rows[21][:expected_departure]

    assert_equal ['Inverness', 'Birmingham New Street', 'Metro Centre', 'Carlisle', 'Manchester Airport'], rows[2..6].map { |r| r[:from] }

    assert_equal [4, 2, 5, 1, 9, 7, nil], rows[2..8].map { |r| r[:platform] }

    assert_equal ['London Kings Cross', '**Terminates**', 'Morpeth', '**Terminates**', '**Terminates**'], rows[2..6].map { |r| r[:to] }
  end

  def test_over_date_change
    stub_request(:get, "realtime.nationalrail.co.uk/virgintrains/summary.aspx?T=KGX").to_return(html_body("fixtures/virgin_live_departure_boards/2011-02-14-2346.10/summary.aspx?T=KGX"))
    Timecop.travel(Time.zone.parse("2011-02-14 23:46:10"))

    rows = @boards.summary("KGX")

    assert_equal [time_today("23:53"), time_tomorrow("00:01"), nil, nil, nil, time_tomorrow("00:19"), time_tomorrow("00:26"), nil, time_tomorrow("00:42"), nil, nil, time_tomorrow("01:42")], rows.map { |r| r[:timetabled_arrival] }
    assert_equal [nil, nil, time_tomorrow("00:04"), time_tomorrow("00:06"), time_tomorrow("00:11"), nil, nil, time_tomorrow("00:36"), nil, time_tomorrow("01:06"), time_tomorrow("01:36"), nil], rows.map { |r| r[:timetabled_departure] }
  end

  def test_without_platform_column
    stub_request(:get, "realtime.nationalrail.co.uk/virgintrains/summary.aspx?T=ABD").to_return(html_body("fixtures/virgin_live_departure_boards/2011-04-07-2159.15/summary.aspx?T=ABD"))
    Timecop.travel(Time.zone.parse("2011-04-07 21:59:15"))

    rows = @boards.summary("ABD")

    assert_equal "Glasgow Queen Street", rows[0][:from]
    assert_equal Time.zone.parse("2011-04-07 22:13"), rows[0][:timetabled_arrival]

    assert_equal "Aberdeen", rows[1][:from]
    assert_equal Time.zone.parse("2011-04-07 22:30"), rows[1][:timetabled_departure]
  end

  def test_circular_route
    stub_request(:get, "realtime.nationalrail.co.uk/virgintrains/summary.aspx?T=GLC").to_return(html_body("fixtures/virgin_live_departure_boards/2011-04-07-2155.26/summary.aspx?T=GLC"))
    Timecop.travel(Time.zone.parse("2011-04-07 21:55:26"))

    rows = @boards.summary("GLC")

    assert_equal "Glasgow Central", rows[17][:from]
    assert_equal Time.zone.parse("2011-04-07 22:15"), rows[17][:timetabled_departure]
    assert_equal true, rows[17][:circular_route]

    assert_equal "Newton", rows[18][:from]
    assert_equal Time.zone.parse("2011-04-07 22:15"), rows[18][:timetabled_arrival]
  end

  private

  def html_body(filename)
    {
      :body => File.open(File.join(File.dirname(__FILE__), filename)).read,
      :headers => { "Content-Type" => "text/html" }
    }
  end
end