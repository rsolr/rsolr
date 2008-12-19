# don't run this test in jruby,
# the curb gem is a c extension based gem, jruby has no support for this
unless defined?(JRUBY_VERSION)

  require File.join(File.dirname(__FILE__), '..', 'test_helpers')
  
  require File.join(File.dirname(__FILE__), 'http_test_methods')

  class CurbTest < Test::Unit::TestCase
  
    def setup
      @c ||= Solr::HTTP.connect(URL, :curb)
    end
  
    include HTTPTestMethods
  
  end
  
end