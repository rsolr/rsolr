require File.join(File.dirname(__FILE__), '..', 'test_helpers')

require File.join(File.dirname(__FILE__), 'test_methods')

class NetHTTPTest < Test::Unit::TestCase
  
  def setup
    @c ||= Solr::HTTPClient.connect(URL, :net_http)
  end
  
  include HTTPClientTestMethods
  
end