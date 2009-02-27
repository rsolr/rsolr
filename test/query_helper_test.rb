require File.join(File.dirname(__FILE__), 'test_helpers.rb')

class RSolrQueryHelperTest < RSolrBaseTest
  
  H = RSolr::Query::Helper
  
  test 'pre_value' do
    value = 'the man'
    assert_equal 'the man', H.prep_value(value, false)
    assert_equal "\"the man\"", H.prep_value(value, :quote=>true)
  end
  
  test 'build_query' do
    assert_equal 'testing', H.build_query('testing')
    assert_equal '"testing"', H.build_query('testing', :quote=>true)
    assert_equal 'testing again', H.build_query(['testing', 'again'])
    assert_equal '"testing" "again"', H.build_query(['testing', 'again'], :quote=>true)
    assert_equal 'name:whatever', H.build_query({:name=>'whatever'})
    assert_equal 'name:"whatever"', H.build_query({:name=>'whatever'}, :quote=>true)
    assert_equal 'sam name:whatever i am', H.build_query(['sam', {:name=>'whatever'}, 'i', 'am'])
    assert_equal 'testing AND blah', H.build_query(['testing', 'blah'], :join=>' AND ')
  end
  
  test 'start_for' do
    per_page = 8
    current_page = 2
    assert_equal 8, H.start_for(current_page, per_page)
  end
  
end