# These are all of the test methods used by the various connection + adapter tests
# Currently: Direct and HTTP
# By sharing these tests, we can make sure the adapters are doing what they're suppossed to
# while staying "dry"

module ConnectionTestMethods
  
  
  #def teardown
  #  @solr.delete_by_query('id:[* TO *]')
  #  @solr.commit
  #  assert_equal 0, @solr.query(:q=>'*:*').docs.size
  #end
  
  def test_default_options
    assert_equal '/select', @solr.adapter.default_options[:select_path]
    assert_equal '/update', @solr.adapter.default_options[:update_path]
    assert_equal '/admin/luke', @solr.adapter.default_options[:luke_path]
  end
  
  # setting adapter options in Solr.connect method should set them in the adapter
  def test_set_adapter_options
    solr = RSolr.connect(:select_path=>'/select2')
    assert_equal '/select2', solr.adapter.opts[:select_path]
  end
  
  # setting connection options in Solr.connect method should set them in the connection
  def test_set_connection_options
    solr = RSolr.connect(:default_wt=>:json)
    assert_equal :json, solr.opts[:default_wt]
  end
  
  # If :wt is NOT :ruby, the format doesn't get wrapped in a Solr::Response class
  # Raw ruby can be returned by using :wt=>'ruby', not :ruby
  def test_raw_response_formats
    ruby_response = @solr.query(:q=>'*:*', :wt=>'ruby')
    assert ruby_response[:body].is_a?(String)
    assert ruby_response[:body]=~%r('wt'=>'ruby')
    # xml?
    xml_response = @solr.query(:q=>'*:*', :wt=>'xml')
    assert xml_response[:body]=~%r(<str name="wt">xml</str>)
    # json?
    json_response = @solr.query(:q=>'*:*', :wt=>'json')
    assert json_response[:body]=~%r("wt":"json")
  end
  
  def test_query_responses
    r = @solr.query(:q=>'*:*')
    assert r.is_a?(RSolr::Response::Query::Base)
    # catch exceptions for bad queries
    assert_raise RSolr::RequestError do
      @solr.query(:q=>'!')
    end
  end
  
  def test_query_response_docs
    @solr.add(:id=>1, :price=>1.00, :cat=>['electronics', 'something else'])
    @solr.commit
    r = @solr.query(:q=>'*:*')
    assert r.is_a?(RSolr::Response::Query::Base)
    assert_equal Array, r.docs.class
    first = r.docs.first
    
    # test the has? method
    assert first.has?('price', 1.00)
    assert ! first.has?('price', 10.00)
    assert first.has?('cat', 'electronics')
    assert first.has?('cat', 'something else')
    assert first.has?(:cat, 'something else')
    
    assert first.has?('cat', /something/)
    
    # has? only works with strings at this time
    assert first.has?(:cat)
    
    assert false == first.has?('cat', /zxcv/)
  end
  
  def test_add
    assert_equal 0, @solr.query(:q=>'*:*').total
    update_response = @solr.add(:id=>100)
    assert update_response.is_a?(RSolr::Response::Update)
    #
    @solr.commit
    assert_equal 1, @solr.query(:q=>'*:*').total
  end
  
  def test_delete_by_id
    @solr.add(:id=>100)
    @solr.commit
    total = @solr.query(:q=>'*:*').total
    assert_equal 1, total
    delete_response = @solr.delete_by_id(100)
    @solr.commit
    assert delete_response.is_a?(RSolr::Response::Update)
    total = @solr.query(:q=>'*:*').total
    assert_equal 0, total
  end
  
  def test_delete_by_query
    @solr.add(:id=>1, :name=>'BLAH BLAH BLAH')
    @solr.commit
    assert_equal 1, @solr.query(:q=>'*:*').total
    response = @solr.delete_by_query('name:BLAH BLAH BLAH')
    @solr.commit
    assert response.is_a?(RSolr::Response::Update)
    assert_equal 0, @solr.query(:q=>'*:*').total
  end
  
  def test_index_info
    response = @solr.index_info
    assert response.is_a?(RSolr::Response::IndexInfo)
    # make sure the ? methods are true/false
    assert [true, false].include?(response.current?)
    assert [true, false].include?(response.optimized?)
    assert [true, false].include?(response.has_deletions?)
  end
  
  def test_expand_args
    assert_equal 'blah', @solr.expand_args(['blah'])
    expected_hash = {:a=>:b}
    assert_equal expected_hash, @solr.expand_args([expected_hash])
    assert_equal ['blah', expected_hash], @solr.expand_args(['blah', expected_hash])
  end
  
  #def test_that_request_path_can_be_set_with_the_first_argument
  #  @solr.query('/blah')
  #end
  
end