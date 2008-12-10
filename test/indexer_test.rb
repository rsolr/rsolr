require File.join(File.dirname(__FILE__), 'test_helpers')

class IndexerTest < Test::Unit::TestCase
  
  def test_something
    data = nil
    mapping = {
      
    }
    i = Solr::Indexer.new(Solr.connect(:http), mapping)
    i.index([])
  end
  
end