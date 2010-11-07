# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{national-rail}
  s.version = "0.3.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["James Mead"]
  s.date = %q{2010-11-07}
  s.email = %q{james@floehopper.org}
  s.files = ["lib/national-rail", "lib/national-rail/index.html", "lib/national-rail/journey_planner.rb", "lib/national-rail/live_departure_boards.rb", "lib/national-rail/station_list.rb", "lib/national-rail/stations.kml", "lib/national-rail/virgin_live_departure_boards.rb", "lib/national-rail.rb"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{national-rail}
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{A Ruby API for the National Rail website}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mechanize>, ["~> 1.0.0"])
      s.add_runtime_dependency(%q<hpricot>, ["~> 0.8.2"])
      s.add_runtime_dependency(%q<activesupport>, ["~> 3.0.0"])
    else
      s.add_dependency(%q<mechanize>, ["~> 1.0.0"])
      s.add_dependency(%q<hpricot>, ["~> 0.8.2"])
      s.add_dependency(%q<activesupport>, ["~> 3.0.0"])
    end
  else
    s.add_dependency(%q<mechanize>, ["~> 1.0.0"])
    s.add_dependency(%q<hpricot>, ["~> 0.8.2"])
    s.add_dependency(%q<activesupport>, ["~> 3.0.0"])
  end
end
