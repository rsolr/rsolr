describe RSolr do
  
  context "method_missing" do
    
    it 'a non-existent method should be forwarded to #method_missing and then to #request' do
      client = RSolr::Client.new nil
      client.should_receive(:request).
        with('/music', :q=>'Coltrane')
      client.music :q=>'Coltrane'
    end
    
  end
  
end