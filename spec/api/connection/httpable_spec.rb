describe RSolr::Connection::Httpable do
  
  # calls #let to set "net_http" as method accessor
  class R
    include RSolr::Connection::Httpable
  end
  
  module HttpableHelper
    def self.included base
      base.let(:httpable){R.new}
    end
  end
  
  context 'new' do
    
    include HttpableHelper
    
    it 'should define an intialize method that accepts a hash argument' do
      lambda{R.new({})}.should_not raise_error 
    end
  
    it 'should have an #opts attribute after creation' do
      httpable.should respond_to(:opts)
    end
  
    it 'should have an #uri attribute after creation' do
      httpable.should respond_to(:uri)
    end
    
  end
  
  context 'opts and uri' do
    
    it 'should allow setting the opts' do
      opts = {:url=>'blah'}
      r = R.new(opts)
      r.opts.should == opts
    end
    
    it 'should parser the url option into a URI object' do
      opts = {:url => 'http://xyz:1010/solr'}
      r = R.new(opts)
      r.uri.should be_a(URI)
      r.uri.host.should == 'xyz'
    end
    
  end
  
  context :create_http_context do
    
    include HttpableHelper
    
    it "should build a simple GET context" do
      r = httpable
      result = r.create_request_context('/select', :q=>'a', :fq=>'b')
      expected = {:path=>"/solr/select?q=a&fq=b", :params=>{:q=>"a", :fq=>"b"}, :data=>nil, :query=>"q=a&fq=b", :host=>"http://127.0.0.1:8983"}
      
      result.keys.all? {|v| expected.keys.include?(v) }
      result.values.all? {|v| expected.values.include?(v) }
    end
    
    it "should build a POST context" do
      r = httpable
      result = r.create_request_context('update', {:wt => :xml}, '<commit/>')
      expected_keys = [:uri, :headers, :data]
      result.keys == expected_keys
      result[:uri].path.should == "/solr/update"
      result[:uri].query.should == 'wt=xml'
      result[:uri].params.should == {:wt=>:xml}
      result[:headers].should == {"Content-Type"=>"text/xml; charset=utf-8"}
      result[:data].should == "<commit/>"
    end
    
    it "should raise an exception when trying to use POST data AND :method => :post" do
      r = httpable
      lambda{
        r.create_request_context('/update', {:wt => :xml}, '<commit/>', :method => :post)
      }.should raise_error("Don't send POST data when using :method => :post")
    end
    
    it "should form-encoded POST context" do
      r = httpable
      result = r.create_request_context('select', {:q => 'some gigantic query string that is too big for GET (for example)'}, nil, :method => :post)
      result[:uri].path.should == "/solr/select"
      result[:uri].params.should == {:q=>"some gigantic query string that is too big for GET (for example)"}
      result[:headers].should == {"Content-Type"=>"application/x-www-form-urlencoded"}
      result[:data].should == "q=some+gigantic+query+string+that+is+too+big+for+GET+%28for+example%29"
    end
    
  end
  
  context :request do
    
    include HttpableHelper
    
    it "should be able to build a request context" do
      httpable.should_receive(:execute_request).
        with(hash_including({:data => nil, :uri => an_instance_of(URI::HTTP)})).
          and_return({:status_code => 200})
      response = httpable.request '/admin/ping'
    end
    
    it "should fail with a non-200 status code" do
      httpable.should_receive(:execute_request).
        with(hash_including({:data => nil, :uri => an_instance_of(URI::HTTP)})).
          and_return({:status_code => 503})
      lambda{
        response = httpable.request '/admin/ping'
      }.should raise_error(RSolr::RequestError)
    end
    
    it 'should send a get to itself with params' do
      httpable.should_receive(:get).
        with(an_instance_of(URI::HTTP)).
          and_return([200, {}, ""])
      r = httpable.request('/blahasdf', :id=>1)
    end
    
    it 'should raise an error if the status_code is not 200' do
      httpable.should_receive(:get).
        with(an_instance_of(URI::HTTP)).
          and_return( [404, {}, "Not Found"] )
      lambda{
        httpable.request('/blah', :id=>1).should == true
      }.should raise_error(/404/)
    end
    
    it 'should send a post to itself if data is supplied' do
      httpable.should_receive(:post).
        with(an_instance_of(URI::HTTP), "<commit/>", {"Content-Type"=>"text/xml; charset=utf-8"}).
          and_return([200, {}, ""])
      r = httpable.request('/blah', {:id=>1}, "<commit/>")#.should == expected_response
      r[:request][:data].should == "<commit/>"
      r[:request][:headers].should == {"Content-Type"=>"text/xml; charset=utf-8"}
      r[:request][:uri].should be_a(URI::HTTP)
    end
    
    it 'should send a post to itself when :method=>:post is set even if no POST data is supplied' do
      httpable.should_receive(:post).
        with(an_instance_of(URI::HTTP), "q=testing", {"Content-Type"=>"application/x-www-form-urlencoded"}).
          and_return([200, {}, ""])
      context = httpable.request('/blah', {:q => "testing"}, :method => :post)#.should == expected_response
      response = context[:response]
      response[:body].should == ""
      response[:status_code].should == 200
      response[:headers].should == {}
      # 
      context[:request][:headers].should == {"Content-Type"=>"application/x-www-form-urlencoded"}
    end
    
  end
  
end
