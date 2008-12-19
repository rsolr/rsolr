#require File.join(File.dirname(__FILE__), '..', 'test_helpers')

require File.join(File.dirname(__FILE__), 'http_test_methods')

class NetHTTPTest < Test::Unit::TestCase
  
  def setup
    @c ||= Solr::HTTP.connect(URL, :net_http)
  end
  
  include HTTPTestMethods
  
end