require 'rubygems'
require 'bundler'
Bundler.setup(:default, :development)

require 'test/unit'
require 'webmock/test_unit'
require 'timecop'

require 'national-rail'

module TimeTestHelper
  def time(hhmm, date = Date.today)
    Time.zone.parse("#{date} #{hhmm}")
  end

  def time_yesterday(hhmm)
    time(hhmm, Date.yesterday)
  end

  def time_today(hhmm)
    time(hhmm)
  end

  def time_tomorrow(hhmm)
    time(hhmm, Date.tomorrow)
  end
end