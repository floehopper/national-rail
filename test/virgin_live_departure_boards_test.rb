require File.join(File.dirname(__FILE__), 'test_helper')

class VirginLiveDepartureBoardsTest < Test::Unit::TestCase

  def test_sample
    stub_request(:get, "realtime.nationalrail.co.uk/virgintrains/summary.aspx?T=NCL").to_return(html_body("fixtures/virgin_live_departure_boards/2010-12-28-1254.22/summary.aspx?T=NCL"))
    boards = NationalRail::VirginLiveDepartureBoards.new
    rows = boards.summary("NCL")

    assert_equal 'Bristol Temple Meads', rows[0].attributes[:from]
    assert_equal '1236', rows[0].attributes[:timetabled_arrival]
    assert_equal '1251', rows[0].attributes[:expected_arrival]
    assert_equal '2', rows[0].attributes[:platform]
    assert_equal 'Edinburgh', rows[0].attributes[:to]
    assert_equal '1240', rows[0].attributes[:timetabled_departure]
    assert_equal '1253', rows[0].attributes[:expected_departure]
    assert_equal 'http://realtime.nationalrail.co.uk/virgintrains/train.aspx?T=NWCSTLE+&J=1371985&R=0', rows[0].attributes[:details_url]

    assert_equal 'London Kings Cross', rows[1].attributes[:from]
    assert_equal '1255', rows[1].attributes[:timetabled_arrival]
    assert_equal '1258', rows[1].attributes[:expected_arrival]
    assert_equal '2', rows[1].attributes[:platform]
    assert_equal 'Edinburgh', rows[1].attributes[:to]
    assert_equal '1257', rows[1].attributes[:timetabled_departure]
    assert_equal '1258', rows[1].attributes[:expected_departure]
    assert_equal 'http://realtime.nationalrail.co.uk/virgintrains/train.aspx?T=NWCSTLE+&J=1364614&R=0', rows[1].attributes[:details_url]
  end

  private

  def html_body(filename)
    {
      :body => File.open(File.join(File.dirname(__FILE__), filename)).read,
      :headers => { "Content-Type" => "text/html" }
    }
  end
end