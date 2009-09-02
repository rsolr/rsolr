require 'helper'
require 'http_client/test_methods'

class NetHTTPTest < RSolrBaseTest
  
  def setup
    @c ||= RSolr::HTTPClient::connect(:url=>URL)
  end
  
  include HTTPClientTestMethods
  
end