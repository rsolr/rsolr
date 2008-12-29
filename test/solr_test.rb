require File.join(File.dirname(__FILE__), 'test_helpers.rb')

class SolrTest < SolrBaseTest
  
  def test_adapter_types
    solr = Solr.connect(:http)
    assert Solr::Connection::Adapter::HTTP, solr.adapter.class
    if defined?(JRUBY_VERSION)
      solr = Solr.connect(:direct)
      assert Solr::Connection::Adapter::Direct, solr.adapter.class
    end
  end
  
end