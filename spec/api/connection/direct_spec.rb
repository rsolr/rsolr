if jruby?
  
  describe RSolr::Connection::Direct do
    
    it 'should accept an options hash' do
      rsolr = RSolr::Connection::Direct.new(:dist_dir=>solr_dist_dir, :home_dir=>solr_home_dir)
      rsolr.request('/select', :q=>'*:*').should be_a Hash
      rsolr.connection.close
    end
    
    it 'should accept a SolrCore' do
      core = new_solr_core solr_home_dir, solr_data_dir
      rsolr = RSolr::Connection::Direct.new(core)
      rsolr.request('/select', :q=>'*:*').should be_a Hash
      rsolr.connection.close
    end
    
    it 'should accept a DirectSolrConnection' do
      dc = org.apache.solr.servlet.DirectSolrConnection.new(solr_home_dir, solr_data_dir, nil)
      rsolr = RSolr::Connection::Direct.new dc
      rsolr.request('/select', :q=>'*:*').should be_a Hash
      rsolr.connection.close
    end
  
  end
  
end