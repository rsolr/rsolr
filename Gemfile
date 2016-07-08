source "https://rubygems.org"

gemspec

gem "builder", ">= 2.1.2"

if defined? RUBY_VERSION and RUBY_VERSION < "1.9"
  gem 'nokogiri', "< 1.6"
end

if defined? RUBY_VERSION
  if RUBY_VERSION < "2.2.2"
    gem "activesupport", "< 5.0.0"
  end

  if RUBY_VERSION < "1.9"
    gem 'nokogiri', "< 1.6"
  end
end
