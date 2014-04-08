# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "rox-client-ruby"
  gem.homepage = "https://github.com/lotaris/rox-client-ruby"
  gem.license = "MIT"
  gem.summary = %Q{Ruby utilities to send results to ROX Center.}
  gem.description = %Q{Collects test results and uploads them to a ROX Center server.}
  gem.email = "simon.oulevay@lotaris.com"
  gem.authors = ["Simon Oulevay"]
  gem.files = Dir["lib/**/*.rb"] + %w(Gemfile LICENSE.txt README.md VERSION)
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

# version tasks
require 'rake-version'
RakeVersion::Tasks.new do |v|
  v.copy 'lib/rox-client-ruby.rb'
end

require 'rspec/core/rake_task'
desc "Run specs"
RSpec::Core::RakeTask.new do |t|
  #t.pattern = "./spec/**/*_spec.rb" # don't need this, it's default.
  # Put spec opts in a file named .rspec in root
end

task default: :spec
