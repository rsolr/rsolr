require File.join(File.dirname(__FILE__), 'test_helpers')

class ExtPaginationTest < Test::Unit::TestCase
  
  def create_response(params={})
    response = Solr::Response::Query.new(mock_query_response)
    response.extend Solr::Ext::Pagination::Response
    response.params.merge! params
    response
  end
  
  def test_math
    response = create_response({'rows'=>5})
    assert_equal response.params['rows'], response.per_page
    assert_equal 26, response.total
    assert_equal 1, response.current_page
    assert_equal 6, response.page_count
    
    # now switch the rows (per_page)
    # total and current page should remain the same value
    # page_count should change
    
    response = create_response({'rows'=>2})
    assert_equal response.params['rows'], response.per_page
    assert_equal 26, response.total
    assert_equal 1, response.current_page
    assert_equal 13, response.page_count
    
    # now switch the start
    
    response = create_response({'rows'=>3})
    response.instance_variable_set '@start', 4
    assert_equal response.params['rows'], response.per_page
    assert_equal 26, response.total
    # 2 per page, currently on the 10th item
    assert_equal 1, response.current_page
    assert_equal 9, response.page_count
  end
  
end