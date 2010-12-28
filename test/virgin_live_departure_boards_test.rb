require File.join(File.dirname(__FILE__), 'test_helper')

class VirginLiveDepartureBoardsTest < Test::Unit::TestCase

  def test_sample
    stub_request(:get, "realtime.nationalrail.co.uk/virgintrains/summary.aspx?T=KGX").to_return(html_body("fixtures/virgin_live_departure_boards/sample/summary.html"))
    boards = NationalRail::VirginLiveDepartureBoards.new
    rows = boards.summary("KGX")

    assert_equal "London\nKings Cross", rows[0].attributes[:from]
    assert_equal '', rows[0].attributes[:timetabled_arrival]
    assert_equal '', rows[0].attributes[:expected_arrival]
    assert_equal '8', rows[0].attributes[:platform]
    assert_equal 'Leeds', rows[0].attributes[:to]
    assert_equal '1210', rows[0].attributes[:timetabled_departure]
    assert_equal 'On time', rows[0].attributes[:expected_departure]
    assert_equal 'http://realtime.nationalrail.co.uk/virgintrains/train.aspx?T=KNGX++++&J=1369041&R=0', rows[0].attributes[:details_url]
  end

  private

  def html_body(filename)
    {
      :body => File.open(File.join(File.dirname(__FILE__), filename)).read,
      :headers => { "Content-Type" => "text/html" }
    }
  end
end