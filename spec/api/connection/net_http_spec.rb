describe RSolr::Connection::NetHttp do
  
  # calls #let to set "net_http" as method accessor
  module NetHttpHelper
    def self.included base
      base.let(:net_http){ RSolr::Connection::NetHttp.new }
    end
  end
  
  context '#request' do
    
    include NetHttpHelper
    
    it 'should forward simple, non-data calls to #get' do
      net_http.should_receive(:create_http_context).
        with("/select", {:q=>"a"}, nil, {}).
          and_return(:path=>"/solr/select?q=a", :params=>{:q=>"a"}, :data=>nil, :query=>"q=a", :host=>"http://127.0.0.1:8983")
      net_http.should_receive(:get).
        with("/solr/select?q=a").
          and_return([200, 'OK', ''])
      net_http.request('/select', :q=>'a')
    end
    
    it 'should forward :method=>:post calls to #post with a special header' do
      net_http.should_receive(:post).
        with("/solr/select", "q=a", {"Content-Type"=>"application/x-www-form-urlencoded"}).
          and_return([200, "OK", ""])
      net_http.request('/select', {:q=>'a'}, :method=>:post)
    end
    
    it 'should forward data calls to #post' do
      net_http.should_receive(:post).
        with("/solr/update", "<optimize/>", {"Content-Type"=>"text/xml; charset=utf-8"}).
          and_return([200, "OK", ""])
      net_http.request('/update', {}, '<optimize/>')
    end
    
  end
  
  context 'connection' do
    
    include NetHttpHelper
    
    it 'will create an instance of Net::HTTP' do
      net_http.send(:connection).should be_a(Net::HTTP)
    end
    
  end
  
  context 'get/post' do
    
    include NetHttpHelper
    
    it 'should make a GET request as expected' do
      net_http_response = mock('net_http_response')
      net_http_response.should_receive(:code).
        and_return(200)
      net_http_response.should_receive(:body).
        and_return('The Response')
      net_http_response.should_receive(:message).
        and_return('OK')
      c = net_http.send(:connection)
      c.should_receive(:get).
        with('/solr/select?q=1').
          and_return(net_http_response)
      
      context = net_http.send(:get, '/solr/select?q=1')
      context.should be_a(Array)
      
      context.size.should == 3
      
      context[0].should == 200
      context[1].should == 'OK'
      context[2].should == 'The Response'
    end
    
    it 'should make a POST request as expected' do
      net_http_response = mock('net_http_response')
      net_http_response.should_receive(:code).
        and_return(200)
      net_http_response.should_receive(:body).
        and_return('The Response')
      net_http_response.should_receive(:message).
        and_return('OK')
      c = net_http.send(:connection)
      c.should_receive(:post).
        with('/solr/update', '<rollback/>', {}).
          and_return(net_http_response)
      context = net_http.send(:post, '/solr/update', '<rollback/>')
      context.should be_a(Array)
      
      context.size.should == 3
      
      context[0].should == 200
      context[1].should == 'OK'
      context[2].should == 'The Response'
    end
    
  end
  
  context 'build_url' do
    
    include NetHttpHelper
    
    it 'should incude the base path to solr' do
      result = net_http.send(:build_url, '/select', :q=>'*:*', :check=>'{!}')
      # this is a non-ordered hash work around,
      #   -- the order of the parameters in the resulting url will be different depending on the ruby distribution/platform
      # yuk.
      begin
        result.should == '/solr/select?check=%7B%21%7D&q=%2A%3A%2A'
      rescue
        result.should == '/solr/select?q=%2A%3A%2A&check=%7B%21%7D'
      end
    end
    
  end
  
  context 'encode_utf8' do
    
    include NetHttpHelper
    
    it 'should encode response body as utf-8' do
      string = 'testing'
      if RUBY_VERSION =~ /1\.9/
        string.encoding.should == Encoding::US_ASCII
        encoded_string = net_http.send(:encode_utf8, string)
        string.encoding.should == Encoding::UTF_8
      else
        encoded_string = net_http.send(:encode_utf8, string)
        encoded_string.should == string
      end
    end
    
  end
  
end
