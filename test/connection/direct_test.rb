if defined?(JRUBY_VERSION)
  
  require 'helper'
  require 'connection/test_methods'
  
  class ConnectionDirectTest < RSolrBaseTest
    
    include ConnectionTestMethods
    
    attr :dist
    attr :home
    
    def setup
      base = File.expand_path( File.dirname(__FILE__) )
      @dist = File.join(base, '..', '..', 'solr')
      @home = File.join(dist, 'example', 'solr')
      @solr = RSolr.connect(:direct, :home_dir=>@home, :dist_dir=>@dist)
      @solr.delete_by_query('*:*')
      @solr.commit
    end
    
    def teardown
      @solr.adapter.close
    end
    
    def test_new_connection_with_existing_core
      Dir["#{@dist}/dist/*.jar"].each { |p| require p }
      dc = org.apache.solr.servlet.DirectSolrConnection.new(@home, "#{@home}/data", nil)
      adapter = RSolr::Connection::Direct.new dc
      s = RSolr::Connection::Base.new(adapter)
      assert_equal Hash, s.request('/admin/ping').class
      adapter.close
    end
    
  end
  
end