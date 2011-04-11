# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{national-rail}
  s.version = "0.4.11"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["James Mead"]
  s.date = %q{2011-04-11}
  s.description = %q{Includes journey planner, live departure boards (both National Rail & Virgin), and a station list with GPS co-ordinates.}
  s.email = %q{james@floehopper.org}
  s.files = ["lib/national-rail", "lib/national-rail.rb", "lib/national-rail/journey_planner", "lib/national-rail/journey_planner.rb", "lib/national-rail/journey_planner/details_page_parser.rb", "lib/national-rail/live_departure_boards.rb", "lib/national-rail/station_list.rb", "lib/national-rail/stations.kml", "lib/national-rail/version.rb", "lib/national-rail/virgin_live_departure_boards", "lib/national-rail/virgin_live_departure_boards.rb", "lib/national-rail/virgin_live_departure_boards/details_page_parser.rb"]
  s.homepage = %q{http://github.com/floehopper/national-rail}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{national-rail}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{A Ruby API for the National Rail website}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mechanize>, ["~> 1.0.0"])
      s.add_runtime_dependency(%q<hpricot>, ["~> 0.8.2"])
      s.add_runtime_dependency(%q<nokogiri>, ["~> 1.4.4"])
      s.add_runtime_dependency(%q<activesupport>, ["~> 3.0.0"])
      s.add_runtime_dependency(%q<ffi>, ["= 0.6.3"])
      s.add_runtime_dependency(%q<tidy_ffi>, ["~> 0.1.3"])
      s.add_runtime_dependency(%q<i18n>, ["~> 0.4.1"])
      s.add_runtime_dependency(%q<tzinfo>, ["~> 0.3.23"])
      s.add_runtime_dependency(%q<htmlentities>, ["~> 4.2.2"])
      s.add_development_dependency(%q<webmock>, ["~> 1.6.1"])
      s.add_development_dependency(%q<timecop>, ["~> 0.3.4"])
    else
      s.add_dependency(%q<mechanize>, ["~> 1.0.0"])
      s.add_dependency(%q<hpricot>, ["~> 0.8.2"])
      s.add_dependency(%q<nokogiri>, ["~> 1.4.4"])
      s.add_dependency(%q<activesupport>, ["~> 3.0.0"])
      s.add_dependency(%q<ffi>, ["= 0.6.3"])
      s.add_dependency(%q<tidy_ffi>, ["~> 0.1.3"])
      s.add_dependency(%q<i18n>, ["~> 0.4.1"])
      s.add_dependency(%q<tzinfo>, ["~> 0.3.23"])
      s.add_dependency(%q<htmlentities>, ["~> 4.2.2"])
      s.add_dependency(%q<webmock>, ["~> 1.6.1"])
      s.add_dependency(%q<timecop>, ["~> 0.3.4"])
    end
  else
    s.add_dependency(%q<mechanize>, ["~> 1.0.0"])
    s.add_dependency(%q<hpricot>, ["~> 0.8.2"])
    s.add_dependency(%q<nokogiri>, ["~> 1.4.4"])
    s.add_dependency(%q<activesupport>, ["~> 3.0.0"])
    s.add_dependency(%q<ffi>, ["= 0.6.3"])
    s.add_dependency(%q<tidy_ffi>, ["~> 0.1.3"])
    s.add_dependency(%q<i18n>, ["~> 0.4.1"])
    s.add_dependency(%q<tzinfo>, ["~> 0.3.23"])
    s.add_dependency(%q<htmlentities>, ["~> 4.2.2"])
    s.add_dependency(%q<webmock>, ["~> 1.6.1"])
    s.add_dependency(%q<timecop>, ["~> 0.3.4"])
  end
end
