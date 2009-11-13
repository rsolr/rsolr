describe RSolr::Connection::NetHttp do
  
  def new_net_http
    RSolr::Connection::NetHttp.new
  end
  
  context '#request' do
    
    it 'should forward simple, non-data calls to #get' do
      http = new_net_http
      http.should_receive(:get).
        with('/select', :q=>'a').
          and_return({:status_code=>200})
      http.request('/select', :q=>'a') 
    end
    
    it 'should forward :method=>:post calls to #post with a special header' do
      http = new_net_http
      http.should_receive(:post).
        with('/select', 'q=a', {}, {"Content-Type"=>"application/x-www-form-urlencoded"}).
          and_return({:status_code=>200})
      http.request('/select', {:q=>'a'}, :method=>:post)
    end
    
    it 'should forward data calls to #post' do
      http = new_net_http
      http.should_receive(:post).
        with("/update", "<optimize/>", {}, {"Content-Type"=>"text/xml; charset=utf-8"}).
          and_return({:status_code=>200})
      http.request('/update', {}, '<optimize/>')
    end
    
  end
  
  context 'connection' do
    
    it 'will create an instance of Net::HTTP' do
      http = new_net_http
      c = http.send :connection
      c.should be_a(Net::HTTP)
    end
    
  end
  
  context 'get/post' do
    
    it 'should make a GET request as expected' do
      net_http_response = mock('net_http_response')
      net_http_response.should_receive(:code).
        and_return(200)
      net_http_response.should_receive(:body).
        and_return('The Response')
      net_http_response.should_receive(:message).
        and_return('OK')
      http = new_net_http
      #http.should_receive(:build_url).
      #  with('/select', :q=>1).
      #    and_return('/select?q=1')
      c = http.send(:connection)
      c.should_receive(:get).
        with('/solr/select?q=1').
          and_return(net_http_response)
      
      context = http.send(:get, '/select', :q=>1)
      context.should be_a(Hash)
      
      keys = [:data, :body, :status_code, :path, :url, :headers, :params, :message]
      context.keys.size.should == keys.size
      context.keys.all?{|key| keys.include?(key) }.should == true
      
      context[:data].should == nil
      context[:body].should == 'The Response'
      context[:status_code].should == 200
      context[:path].should == '/select'
      context[:url].should == 'http://127.0.0.1:8983/solr/select?q=1'
      context[:headers].should == {}
      context[:params].should == {:q=>1}
      context[:message].should == 'OK'
    end
    
    it 'should make a POST request as expected' do
      net_http_response = mock('net_http_response')
      net_http_response.should_receive(:code).
        and_return(200)
      net_http_response.should_receive(:body).
        and_return('The Response')
      net_http_response.should_receive(:message).
        and_return('OK')
      http = new_net_http
      #http.should_receive(:build_url).
      #  with('/update', {}).
      #    and_return('/update')
      c = http.send(:connection)
      c.should_receive(:post).
        with('/solr/update', '<rollback/>', {}).
          and_return(net_http_response)
      context = http.send(:post, '/update', '<rollback/>')
      context.should be_a(Hash)
      
      keys = [:data, :body, :status_code, :path, :url, :headers, :params, :message]
      context.keys.size.should == keys.size
      context.keys.all?{|key| keys.include?(key) }.should == true
      
      context[:data].should == '<rollback/>'
      context[:body].should == 'The Response'
      context[:status_code].should == 200
      context[:path].should == '/update'
      context[:url].should == 'http://127.0.0.1:8983/solr/update'
      context[:headers].should == {}
      context[:params].should == {}
      context[:message].should == 'OK'
    end
    
  end
  
  context 'build_url' do
    
    it 'should incude the base path to solr' do
      http = new_net_http
      result = http.send(:build_url, '/select', :q=>'*:*', :check=>'{!}')
      # this is a non-ordered hash work around,
      #   -- the order of the parameters in the resulting url will be different depending on the ruby distribution/platform
      begin
        result.should == '/solr/select?check=%7B%21%7D&q=%2A%3A%2A'
      rescue
        result.should == '/solr/select?q=%2A%3A%2A&check=%7B%21%7D'
      end
    end
    
  end
  
  context 'encode_utf8' do
    
    it 'should encode response body as utf-8' do
      http = new_net_http
      string = 'testing'
      if RUBY_VERSION =~ /1\.9/
        string.encoding.should == Encoding::US_ASCII
        encoded_string = http.send(:encode_utf8, string)
        string.encoding.should == Encoding::UTF_8
      else
        encoded_string = http.send(:encode_utf8, string)
        encoded_string.should == string
      end
    end
    
  end
  
end