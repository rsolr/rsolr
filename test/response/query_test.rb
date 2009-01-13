require File.join(File.dirname(__FILE__), '..', 'test_helpers')

class ResponseQueryTest < RSolrBaseTest
  
  def query_response
    RSolr::Response::Query::Base.new(mock_query_response)
  end
  
  def test_accessors
    r = query_response
    assert r.response
    assert_class Array, r.docs
    
    # total and num_found are the same
    assert_equal 26, r.num_found
    assert_equal r.total, r.num_found
    
    # start and offset are the same
    assert_equal 0, r.start
    assert_equal r.offset, r.start
  end
  
  # make sure the docs respond to key and symbol access (using the Mash class)
  def test_doc_string_and_symbol_key_access
    response = query_response
    response.docs.each do |doc|
      assert doc.is_a?(Mash)
      assert_equal doc['id'], doc[:id]
      assert doc.key?(:id)
      assert doc.key?('id')
      if doc[:cat]
        # if this doc has a cat (multiValues) of memory and electronics
        # test the has? method
        if doc[:cat].include?('memory') and doc[:cat].include?('electronics')
          assert doc.has?(:cat, 'memory')
          assert doc.has?(:cat, /elec/)
          assert doc.has?('cat', 'memory')
          assert doc.has?('cat', /elec/)
        end
      end
    end
  end
  
end