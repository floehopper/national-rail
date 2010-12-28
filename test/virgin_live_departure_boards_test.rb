require File.join(File.dirname(__FILE__), 'test_helper')

class VirginLiveDepartureBoardsTest < Test::Unit::TestCase

  def setup
    Time.zone = "London"
    @boards = NationalRail::VirginLiveDepartureBoards.new
  end

  def test_sample
    stub_request(:get, "realtime.nationalrail.co.uk/virgintrains/summary.aspx?T=NCL").to_return(html_body("fixtures/virgin_live_departure_boards/2010-12-28-1254.22/summary.aspx?T=NCL"))
    rows = @boards.summary("NCL")

    assert_equal 'Bristol Temple Meads', rows[0][:from]
    assert_equal time('12:36'), rows[0][:timetabled_arrival]
    assert_equal time('12:51'), rows[0][:expected_arrival]
    assert_equal 2, rows[0][:platform]
    assert_equal 'Edinburgh', rows[0][:to]
    assert_equal time('12:40'), rows[0][:timetabled_departure]
    assert_equal time('12:53'), rows[0][:expected_departure]
    assert_equal 'http://realtime.nationalrail.co.uk/virgintrains/train.aspx?T=NWCSTLE+&J=1371985&R=0', rows[0][:details_url]

    assert_equal 'London Kings Cross', rows[1][:from]
    assert_equal time('12:55'), rows[1][:timetabled_arrival]
    assert_equal time('12:58'), rows[1][:expected_arrival]
    assert_equal 2, rows[1][:platform]
    assert_equal 'Edinburgh', rows[1][:to]
    assert_equal time('12:57'), rows[1][:timetabled_departure]
    assert_equal time('12:58'), rows[1][:expected_departure]
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

  private

  def time(hhmm)
    Time.zone.parse("2010-12-28 #{hhmm}")
  end

  def html_body(filename)
    {
      :body => File.open(File.join(File.dirname(__FILE__), filename)).read,
      :headers => { "Content-Type" => "text/html" }
    }
  end
end