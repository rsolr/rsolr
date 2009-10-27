describe RSolr do
  
  context "method_missing" do
    
    it 'a non-existent method should be forwarded to #method_missing and then to #request' do
      client = RSolr::Client.new nil
      client.should_receive(:request).
        with('/music', :q=>'Coltrane')
      client.music :q=>'Coltrane'
    end
    
  end
  
  context 'update' do
    it 'should forward /update to #request' do
      client = RSolr::Client.new nil
      client.should_receive(:request).
        with('/update', {}, '</commit>')
      client.update '<commit/>'
    end
  end
  
end