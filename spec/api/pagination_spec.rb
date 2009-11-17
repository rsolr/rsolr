describe RSolr::Pagination do
  
  context 'the #page_and_per_page_to_start_and_rows method' do
    
    it 'should properly convert' do
      start,rows = RSolr::Pagination.page_and_per_page_to_start_and_rows 22, 2
      start.should == 42
      rows.should == 2
    end
    
    it 'should properly convert a 0 start' do
      start,rows = RSolr::Pagination.page_and_per_page_to_start_and_rows 0, 2
      start.should == 0
      rows.should == 2
    end
    
    it 'should properly convert a negative start' do
      start,rows = RSolr::Pagination.page_and_per_page_to_start_and_rows -1, 2
      start.should == 0
      rows.should == 2
    end
    
    it 'should properly convert a 0 per-page' do
      start,rows = RSolr::Pagination.page_and_per_page_to_start_and_rows 10, 0
      start.should == 0
      rows.should == 0
    end
    
    it 'should raise RSolr::Pagination::NegativePerPageError' do
      lambda {
        start,rows = RSolr::Pagination.page_and_per_page_to_start_and_rows 10, -1
      }.should raise_error(RSolr::Pagination::NegativePerPageError)
    end
    
  end
  
  context 'mixing in Pagination should give the ["response"]["docs"] some special powers' do
    
    it 'should raise RSolr::Pagination::InvalidSolrResponse when extending a non-solr response hash' do
      lambda{
        {}.extend RSolr::Pagination
      }.should raise_error RSolr::Pagination::InvalidSolrResponse
    end
    
    it 'should extend properly and apply methods to response["docs"]' do
      start = 23
      rows = 10
      num_found = 100
      response = {'response'=>{'docs' => [], 'start'=>start, 'numFound'=>num_found}, 'responseHeader'=>{'params'=>{'rows'=>rows}}}
      response.extend RSolr::Pagination
      docs = response['response']['docs']
      docs.start.should == 23
      docs.per_page.should == 10
      docs.total.should == 100
      docs.current_page.should == 3
      docs.total_pages.should == 10
      docs.previous_page.should == 2
      docs.next_page.should == 4
      docs.has_next?.should == true
      docs.has_previous?.should == true
    end
    
  end
  
end