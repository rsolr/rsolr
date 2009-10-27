unless defined?(JRUBY_VERSION)
  
  require 'helper'
  require 'connection/test_methods'
  
  class NetHttpTest < RSolrBaseTest
  
    include ConnectionTestMethods
    
    def setup
      @solr = RSolr.connect
      @solr.delete_by_query('*:*')
      @solr.commit
    end
    
    # http://www.w3.org/TR/html4/interact/forms.html#submit-format
    
    # due to the way some servers implement their query string parsing,
    # POST is sometimes needed for large query strings.
    # This test simply shows that a large q value will not blow up solr.
    def test_post_for_select
      big_honkin_q = (['ipod']*1000).join(' OR ')
      response = @solr.adapter.request '/select', {:q=>big_honkin_q}, :method=>:post
      assert response
    end
    
  end
  
end