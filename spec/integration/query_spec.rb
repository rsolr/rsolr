describe RSolr::Client do
  
  context 'pagination' do
    
    it 'should raise an error if two pagination args are not set' do
      rsolr = RSolr.connect
      lambda {
        rsolr.paginate_select 100, :q=>'ATOM'
      }.should raise_error
    end
    
    it 'should properly convert page/per-page to start and rows' do
      rsolr = RSolr.connect
      response = rsolr.paginate_select 1, 25, :q=>'ATOM'
      response['responseHeader']['params']['start'].should == '0'
      response['responseHeader']['params']['rows'].should == '25'
    end
    
    it 'should properly convert page/per-page to start and rows, once again' do
      rsolr = RSolr.connect
      response = rsolr.paginate_select 13, 30, :q=>'ATOM'
      response['responseHeader']['params']['start'].should == '360'
      response['responseHeader']['params']['rows'].should == '30'
    end
    
  end
  
end