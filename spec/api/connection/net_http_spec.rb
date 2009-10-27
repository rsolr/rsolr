describe RSolr::Connection::NetHttp do
  
  context '#request' do
    
    it 'should forward simple, non-data calls to #get' do
      http = RSolr::Connection::NetHttp.new
      http.should_receive(:get).
        with('/select', :q=>'a').
          and_return({:status_code=>200})
      http.request('/select', :q=>'a') 
    end
    
    it 'should forward :method=>:post calls to #post with a special header' do
      http = RSolr::Connection::NetHttp.new
      http.should_receive(:post).
        with('/select', 'q=a', {}, {"Content-Type"=>"application/x-www-form-urlencoded"}).
          and_return({:status_code=>200})
      http.request('/select', {:q=>'a'}, :method=>:post)
    end
    
    it 'should forward data calls to #post' do
      http = RSolr::Connection::NetHttp.new
      http.should_receive(:post).
        with("/update", "<optimize/>", {}, {"Content-Type"=>"text/xml; charset=utf-8"}).
          and_return({:status_code=>200})
      http.request('/update', {}, '<optimize/>')
    end
    
  end
  
  context 'connection' do
    
    it 'will receive 2 args when created' do
      http = RSolr::Connection::NetHttp.new
      c = http.send :connection
      c.should be_a(Net::HTTP)
    end
    
  end
  
end