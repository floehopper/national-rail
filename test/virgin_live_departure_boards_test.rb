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
    assert_equal '2', rows[0][:platform]
    assert_equal 'Edinburgh', rows[0][:to]
    assert_equal time('12:40'), rows[0][:timetabled_departure]
    assert_equal time('12:53'), rows[0][:expected_departure]
    assert_equal 'http://realtime.nationalrail.co.uk/virgintrains/train.aspx?T=NWCSTLE+&J=1371985&R=0', rows[0][:details_url]

    assert_equal 'London Kings Cross', rows[1][:from]
    assert_equal time('12:55'), rows[1][:timetabled_arrival]
    assert_equal time('12:58'), rows[1][:expected_arrival]
    assert_equal '2', rows[1][:platform]
    assert_equal 'Edinburgh', rows[1][:to]
    assert_equal time('12:57'), rows[1][:timetabled_departure]
    assert_equal time('12:58'), rows[1][:expected_departure]
    assert_equal 'http://realtime.nationalrail.co.uk/virgintrains/train.aspx?T=NWCSTLE+&J=1364614&R=0', rows[1][:details_url]

    assert_equal 'Inverness', rows[2][:from]
    assert_equal 'Birmingham New Street', rows[3][:from]
    assert_equal 'Metro Centre', rows[4][:from]
    assert_equal 'Carlisle', rows[5][:from]
    assert_equal 'Manchester Airport', rows[6][:from]

    assert_equal 'London Kings Cross', rows[2][:to]
    assert_equal '**Terminates**', rows[3][:to]
    assert_equal 'Morpeth', rows[4][:to]
    assert_equal '**Terminates**', rows[5][:to]
    assert_equal '**Terminates**', rows[6][:to]
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