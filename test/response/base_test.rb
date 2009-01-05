require File.join(File.dirname(__FILE__), '..', 'test_helpers')

class ResponseBaseTest < RSolrBaseTest
  
  def test_accessors
    
    adapter_response = {:body=>mock_query_response}
    
    r = RSolr::Response::Base.new(adapter_response)
    
    assert_class Mash, r.data
    assert_class Mash, r.params
    assert_class Mash, r.header
    
    # make sure the incoming adapter response is the same as the response.input
    assert_equal adapter_response, r.input
    
    assert_equal r.query_time, r.header[:QTime]
    assert_equal r.query_time, r.header['QTime']
    
    assert_equal r.params, r.header[:params]
    assert_equal r.params, r.header['params']
    
    assert_equal '*:*', r.params[:q]
    assert_equal '*:*', r.params['q']
    
    assert_equal 0, r.status
    assert_equal r.status, r.header[:status]
    assert_equal r.status, r.header['status']
    
    assert_equal r.header, r.data[:responseHeader]
    assert_equal r.header, r.data['responseHeader']
    
    assert r.ok?
    
  end
  
end