require File.join(File.dirname(__FILE__), '..', 'test_helpers')

require File.join(File.dirname(__FILE__), 'test_methods')

class NetHTTPTest < RSolrBaseTest
  
  def setup
    @c ||= RSolr::HTTPClient.connect(URL, :net_http)
  end
  
  include HTTPClientTestMethods
  
end