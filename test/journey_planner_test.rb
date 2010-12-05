require "rubygems"
require "bundler"
Bundler.setup(:default, :development)

require "test/unit"
require 'webmock/test_unit'
require "national-rail"

class JourneyPlannerTest < Test::Unit::TestCase

  def setup
    Time.zone = "London"
    @planner = NationalRail::JourneyPlanner.new
  end

  def test_plan
    stub_request(:get, "www.nationalrail.co.uk/").to_return(html_body("index.html"))
    stub_request(:post, "ojp.nationalrail.co.uk/en/s/planjourney/plan").to_return(html_body("summary.html"))
    stub_request(:get, "ojp.nationalrail.co.uk/en/s/timetable/details").with(details_query(3)).to_return(html_body("details.html"))
    rows = @planner.plan(
      :from => "London Kings Cross",
      :to => "Inverness",
      :time => time("08:00")
    )

    assert_equal time("08:10"), rows[0].departure_time
    assert_equal "3", rows[0].number_of_changes
    assert_equal({}, rows[0].details)

    assert_equal time("11:00"), rows[1].departure_time
    assert_equal "2", rows[1].number_of_changes
    assert_equal({}, rows[1].details)

    assert_equal time("12:00"), rows[2].departure_time
    assert_equal "0", rows[2].number_of_changes
    assert_equal ["London Kings Cross"], rows[2].details[:origins]
    assert_equal time("12:00"), rows[2].details[:initial_stop][:departs_at]
    assert_equal "KGX", rows[2].details[:initial_stop][:station_code]

    station_codes = rows[2].details[:stops].map { |s| s[:station_code] }
    assert_equal ["PBO", "YRK", "NCL", "EDB", "HYM", "FKG", "STG", "GLE", "PTH", "PIT", "KIN", "AVM"], station_codes

    arrival_times = rows[2].details[:stops].map { |s| s[:arrives_at].strftime("%H:%M") }
    assert_equal ["12:46", "13:58", "14:58", "16:27", "16:37", "17:04", "17:19", "17:38", "18:00", "18:29", "19:16", "19:29"], arrival_times

    departure_times = rows[2].details[:stops].map { |s| s[:departs_at].strftime("%H:%M") }
    assert_equal ["12:47", "14:04", "15:00", "16:33", "16:38", "17:05", "17:20", "17:40", "18:00", "18:33", "19:17", "19:29"], departure_times

    assert_equal ["Inverness"], rows[2].details[:destinations]
    assert_equal time("20:08"), rows[2].details[:final_stop][:arrives_at]
    assert_equal "INV", rows[2].details[:final_stop][:station_code]
    assert_equal "East Coast", rows[2].details[:company]

    assert_equal time("12:10"), rows[3].departure_time
    assert_equal "3", rows[3].number_of_changes
    assert_equal({}, rows[3].details)

    assert_equal time("15:00"), rows[4].departure_time
    assert_equal "1", rows[4].number_of_changes
    assert_equal({}, rows[4].details)
  end
  
  def test_do_not_attempt_to_parse_details_for_cancelled_trains
    stub_request(:get, "www.nationalrail.co.uk/").to_return(html_body("index.html"))
    stub_request(:post, "ojp.nationalrail.co.uk/en/s/planjourney/plan").to_return(html_body("summary-cancelled-trains.html"))
    stub_request(:get, "ojp.nationalrail.co.uk/en/s/timetable/details").with(details_query(2)).to_return(html_body("details-cancelled-train.html"))
    rows = @planner.plan(
      :from => "Doncaster",
      :to => "Glasgow Central",
      :time => time("14:00")
    )
    rows.each_with_index do |row, index|
      assert_equal "cancelled", rows[index].status, "row: #{index}"
      assert_equal({}, rows[index].details, "row: #{index}")
    end
    assert_not_requested(:get, "ojp.nationalrail.co.uk/en/s/timetable/details", details_query(2))
  end

  private

  def time(hhmm)
    Time.zone.parse("2010-11-22 #{hhmm}")
  end

  def html_body(filename)
    {
      :body => File.open(File.join(File.dirname(__FILE__), filename)).read,
      :headers => { "Content-Type" => "text/html" }
    }
  end

  def details_query(index)
    {
      :query => {
        :id => index.to_s,
        :callingPage => "t",
        :return => "false"
      }
    }
  end
end