require File.join(File.dirname(__FILE__), '..', 'test_helpers')

require File.join(File.dirname(__FILE__), 'test_methods')

class NetHTTPTest < RSolrBaseTest
  
  def setup
    @c ||= RSolr::HTTPClient::Connector.new(:net_http).connect(URL)
  end
  
  include HTTPClientTestMethods
  
end