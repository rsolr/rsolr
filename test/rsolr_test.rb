require File.join(File.dirname(__FILE__), 'test_helpers.rb')

class SolrTest < RSolrBaseTest
  
  def setup
    if defined?(JRUBY_VERSION)
      @solr = RSolr.connect(:adapter=>:direct)
    else
      @solr = RSolr.connect
    end
  end
  
end