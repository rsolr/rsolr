require 'rsolr'
require 'rspec'

FIXTURES_DIR = File.expand_path("fixtures", File.dirname(__FILE__))

RSpec.configure do |c|
  c.filter_run :focus => true
  c.run_all_when_everything_filtered = true
end
