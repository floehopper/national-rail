require "rubygems"
require "rake/gempackagetask"
require "rake/rdoctask"
require "rake/testtask"

require 'bundler/setup'
require 'national-rail'

task :default => :test

desc "Run tests"
Rake::TestTask.new do |t|
  t.libs << 'test'
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end

# This builds the actual gem. For details of what all these options
# mean, and other ones you can add, check the documentation here:
#
#   http://rubygems.org/read/chapter/20
#
spec = Gem::Specification.new do |s|

  # Change these as appropriate
  s.name              = "national-rail"
  s.version           = NationalRail::VERSION
  s.summary           = "A Ruby API for the National Rail website"
  s.description       = "Includes journey planner, live departure boards (both National Rail & Virgin), and a station list with GPS co-ordinates."
  s.author            = "James Mead"
  s.email             = "james@floehopper.org"
  s.homepage          = "http://github.com/floehopper/national-rail"

  s.has_rdoc          = true
  # You should probably have a README of some kind. Change the filename
  # as appropriate
  # s.extra_rdoc_files  = %w(README)
  # s.rdoc_options      = %w(--main README)

  # Add any extra files to include in the gem (like your README)
  s.files             = %w() + Dir.glob("{lib/**/*}").sort
  s.require_paths     = ["lib"]

  # If you want to depend on other gems, add them here, along with any
  # relevant versions
  s.add_dependency("mechanize", "~> 1.0.0")
  s.add_dependency("hpricot", "~> 0.8.2")
  s.add_dependency("nokogiri", "~> 1.4.4")
  s.add_dependency("activesupport", "~> 3.0.0")
  s.add_dependency("ffi", "0.6.3")
  s.add_dependency("tidy_ffi", "~> 0.1.3")
  s.add_dependency("i18n", "~> 0.4.1")
  s.add_dependency("tzinfo", "~> 0.3.23")
  s.add_dependency("htmlentities", "~> 4.2.2")
  s.add_development_dependency("webmock", "~> 1.6.1")
  s.add_development_dependency("timecop", "~> 0.3.4")

  # If your tests use any gems, include them here
  # s.add_development_dependency("mocha") # for example

  # If you want to publish automatically to rubyforge, you'll may need
  # to tweak this, and the publishing task below too.
  s.rubyforge_project = "national-rail"
end

# This task actually builds the gem. We also regenerate a static
# .gemspec file, which is useful if something (i.e. GitHub) will
# be automatically building a gem for this project. If you're not
# using GitHub, edit as appropriate.
#
# To publish your gem online, install the 'gemcutter' gem; Read more 
# about that here: http://gemcutter.org/pages/gem_docs
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Build the gemspec file #{spec.name}.gemspec"
task :gemspec do
  file = File.dirname(__FILE__) + "/#{spec.name}.gemspec"
  File.open(file, "w") {|f| f << spec.to_ruby }
end

task :package => :gemspec

# Generate documentation
Rake::RDocTask.new do |rd|
  
  rd.rdoc_files.include("lib/**/*.rb")
  rd.rdoc_dir = "rdoc"
end

desc 'Clear out RDoc and generated packages'
task :clean => [:clobber_rdoc, :clobber_package] do
  rm "#{spec.name}.gemspec"
end

# If you want to publish to RubyForge automatically, here's a simple 
# task to help do that. If you don't, just get rid of this.
# Be sure to set up your Rubyforge account details with the Rubyforge
# gem; you'll need to run `rubyforge setup` and `rubyforge config` at
# the very least.
begin
  require "rake/contrib/sshpublisher"
  namespace :rubyforge do
    
    desc "Release gem and RDoc documentation to RubyForge"
    task :release => ["rubyforge:release:gem", "rubyforge:release:docs"]
    
    namespace :release do
      desc "Release a new version of this gem"
      task :gem => [:package] do
        require 'rubyforge'
        rubyforge = RubyForge.new
        rubyforge.configure
        rubyforge.login
        rubyforge.userconfig['release_notes'] = spec.summary
        path_to_gem = File.join(File.dirname(__FILE__), "pkg", "#{spec.name}-#{spec.version}.gem")
        puts "Publishing #{spec.name}-#{spec.version.to_s} to Rubyforge..."
        rubyforge.add_release(spec.rubyforge_project, spec.name, spec.version.to_s, path_to_gem)
      end
    
      desc "Publish RDoc to RubyForge."
      task :docs => [:rdoc] do
        config = YAML.load(
          File.read(File.expand_path('~/.rubyforge/user-config.yml'))
        )
 
        host = "#{config['username']}@rubyforge.org"
        remote_dir = "/var/www/gforge-projects/national-rail/" # Should be the same as the rubyforge project name
        local_dir = 'rdoc'
 
        Rake::SshDirPublisher.new(host, remote_dir, local_dir).upload
      end
    end
  end
rescue LoadError
  puts "Rake SshDirPublisher is unavailable or your rubyforge environment is not configured."
end

desc 'Tag the repository in git with gem version number'
task :tag => [:gemspec, :package] do
  if `git diff --cached`.empty?
    if `git tag`.split("\n").include?("v#{spec.version}")
      puts "Version #{spec.version} has already been tagged"
    else
      `git add #{File.expand_path("../#{spec.name}.gemspec", __FILE__)}`
      `git commit -m "Released version #{spec.version}"`
      `git tag v#{spec.version}`
      `git push --tags`
      `git push`
    end
  else
    raise "Unstaged changes still waiting to be committed"
  end
end

desc "Tag and publish the gem to rubygems.org"
task :publish => :tag do
  `gem push pkg/#{spec.name}-#{spec.version}.gem`
end

namespace :generate do
  desc "Generate fresh test fixtures"
  task :fixtures do
    Time.zone = "London"
    NationalRail::VirginLiveDepartureBoards.capture_path = File.join(File.dirname(__FILE__), 'test', 'fixtures', 'virgin_live_departure_boards', Time.now.strftime("%Y-%m-%d-%H%M.%S"))
    boards = NationalRail::VirginLiveDepartureBoards.new
    boards.summary("KGX").each { |row| row.details }
  end
end
