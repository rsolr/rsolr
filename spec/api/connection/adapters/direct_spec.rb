if jruby?
  
  describe RSolr::Connection::Adapters::Direct do
    
    it 'should accept an options hash' do
      opts = {:home_dir=>solr_home_dir}
      RSolr.connect(:direct, opts) do |rsolr|
        rsolr.request('/select', :q=>'*:*').should be_a(Hash)
      end
    end
    
    it 'should accept a SolrCore' do
      core = new_solr_core solr_home_dir, solr_data_dir
      RSolr.connect(:direct, core) do |rsolr|
        rsolr.request('/select', :q=>'*:*').should be_a(Hash)
      end
    end
    
    it 'should accept a DirectSolrConnection' do
      dc = org.apache.solr.servlet.DirectSolrConnection.new(solr_home_dir, solr_data_dir, nil)
      RSolr.connect(:direct, dc) do |rsolr|
        rsolr.request('/select', :q=>'*:*').should be_a(Hash)
      end
    end
  
  end
  
end