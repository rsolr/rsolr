require File.join(File.dirname(__FILE__), 'test_helpers.rb')

class SolrTest < RSolrBaseTest
  
  def test_adapter_types
    solr = RSolr.connect(:http)
    assert RSolr::Connection::Adapter::HTTP, solr.adapter.class
    if defined?(JRUBY_VERSION)
      solr = RSolr.connect(:direct)
      assert RSolr::Connection::Adapter::Direct, solr.adapter.class
    end
  end
  
end