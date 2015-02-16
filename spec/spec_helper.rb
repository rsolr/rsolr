require File.expand_path('../../lib/rsolr', __FILE__)

RSpec.configure do |config|
  config.after { Thread.current[:rsolr_http] = nil }
end
