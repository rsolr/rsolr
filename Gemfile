source "https://rubygems.org"

gemspec

gem "builder", ">= 2.1.2"

group :development do
  gem "rake", ">= 0.9.2"
  gem "rdoc", ">= 3.9"
end

group :test do
  gem "rake", ">= 0.9.2"
  gem "rspec", "~> 2.6"
end

if defined? RUBY_VERSION and RUBY_VERSION < "1.9"
  gem 'nokogiri', "< 1.6"
end
