require File.join(File.dirname(__FILE__), 'test_helpers.rb')

class CoreExtTest < SolrBaseTest
  
  def test_nested_symbol_access
    assert_equal :'test.this!', :test.this!
  end
  
end