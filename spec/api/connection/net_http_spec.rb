describe RSolr::Connection::NetHttp do
  
  # calls #let to set "net_http" as method accessor
  module NetHttpHelper
    def self.included base
      base.let(:net_http){ RSolr::Connection::NetHttp.new }
    end
  end
  
  context 'the connection method' do
    include NetHttpHelper
    it 'will create an instance of Net::HTTP' do
      net_http.send(:connection).should be_a(Net::HTTP)
    end
    it 'should be a singleton' do
      net_http.connection.object_id.should == net_http.connection.object_id
    end
  end
  
  context 'proxy connection' do
    let(:proxy_connection){
      RSolr::Connection::NetHttp.new :url=>'http://localhost:8983/solr', :proxy => 'http://qwerty.com/'
    }
    it 'should have a :proxy AND :url attribute set' do
      proxy_connection.proxy.to_s.should == 'http://qwerty.com/'
      proxy_connection.uri.to_s.should == 'http://localhost:8983/solr/'
    end
  end
  
  context '#request' do
    
    include NetHttpHelper
    
    it 'should forward simple, non-data calls to #get' do
      net_http.should_receive(:get).
        with(an_instance_of(URI::HTTP)).
          and_return([200, 'OK', ''])
      net_http.request('/select', :q=>'a')
    end
    
    it 'should forward :method=>:post calls to #post with a form-urlencoded header' do
      net_http.should_receive(:post).
        with(an_instance_of(URI::HTTP), 'q=a', {"Content-Type"=>"application/x-www-form-urlencoded"}).
          and_return([200, "OK", ""])
      net_http.request('/select', {:q=>'a'}, :method=>:post)
    end
    
    it 'should forward data calls to #post' do
      net_http.should_receive(:post).
        with(an_instance_of(URI::HTTP), "<optimize/>", {"Content-Type"=>"text/xml; charset=utf-8"}).
          and_return([200, "OK", ""])
      net_http.request('/update', {}, '<optimize/>')
    end
    
  end
  
end