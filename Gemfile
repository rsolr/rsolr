source "https://rubygems.org"

gemspec

gem "builder", ">= 2.1.2"

if defined? JRUBY_VERSION
  # HTTP.rb (used by solr_wrapper to download solr for integration testing) fails
  # to download the full contents of files (under jruby)?
  gem "http", '< 5', platforms: :jruby
end

gem 'faraday', ENV['FARADAY_VERSION'] if ENV['FARADAY_VERSION']
