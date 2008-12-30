require File.join(File.dirname(__FILE__), 'test_helpers')

class PaginationTest < Test::Unit::TestCase
  
  def create_response(params={})
    response = Solr::Response::Query::Base.new(mock_query_response)
    response.params.merge! params
    response
  end
  
  # test the Solr::Connection pagination methods
  def test_connection_calculate_start
    dummy_connection = Solr::Connection::Base.new(nil)
    assert_equal 15, dummy_connection.send(:calculate_start, 2, 15)
    assert_equal 450, dummy_connection.send(:calculate_start, 10, 50)
    assert_equal 0, dummy_connection.send(:calculate_start, 0, 50)
  end
  
  def test_connection_modify_params_for_pagination
    dummy_connection = Solr::Connection::Base.new(nil)
    p = dummy_connection.send(:modify_params_for_pagination, {:page=>1})
    assert_equal 0, p[:start]
    assert_equal 10, p[:rows]
    #
    p = dummy_connection.send(:modify_params_for_pagination, {:page=>10, :per_page=>100})
    assert_equal 900, p[:start]
    assert_equal 100, p[:rows]
  end
  
  def test_math
    response = create_response({'rows'=>5})
    assert_equal response.params['rows'], response.per_page
    assert_equal 26, response.total
    assert_equal 1, response.current_page
    assert_equal 6, response.total_pages
    
    # now switch the rows (per_page)
    # total and current page should remain the same value
    # page_count should change
    
    response = create_response({'rows'=>2})
    assert_equal response.params['rows'], response.per_page
    assert_equal 26, response.total
    assert_equal 1, response.current_page
    assert_equal 13, response.total_pages
    
    # now switch the start
    
    response = create_response({'rows'=>3})
    response.instance_variable_set '@start', 4
    assert_equal response.params['rows'], response.per_page
    assert_equal 26, response.total
    # 2 per page, currently on the 10th item
    assert_equal 2, response.current_page
    assert_equal 9, response.total_pages
  end
  
end