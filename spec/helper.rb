require 'rubygems'
require 'bundler'

begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end

require 'simplecov'
SimpleCov.start

require 'rspec'
require 'fakefs/spec_helpers'

Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each{ |f| require f }

require 'rox-client-ruby'
