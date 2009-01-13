unless defined?(JRUBY_VERSION)

  require File.join(File.dirname(__FILE__), '..', 'test_helpers')
  
  require File.join(File.dirname(__FILE__), 'test_methods')

  class AdapterHTTPTest < RSolrBaseTest
  
    include ConnectionTestMethods
  
    def setup
      @solr = RSolr.connect
      @solr.delete_by_query('*:*')
      @solr.commit
    end
  
  end
  
end