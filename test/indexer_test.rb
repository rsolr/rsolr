require File.join(File.dirname(__FILE__), 'test_helpers')

class IndexerTest < RSolrBaseTest
  
  def test_something
    data = nil
    mapping = {}
    i = RSolr::Indexer.new(RSolr.connect, mapping)
    i.index([])
  end
  
end