describe RSolr::Connection::Requestable do
  
  # calls #let to set "net_http" as method accessor
  class R
    include RSolr::Connection::Requestable
  end
  
  module RequestableHelper
    def self.included base
      base.let(:requestable){R.new}
    end
  end
  
  context 'new' do
    
    include RequestableHelper
    
    it 'should define an intialize method that accepts a hash argument' do
      lambda{R.new({})}.should_not raise_error 
    end
  
    it 'should have an #opts attribute after creation' do
      requestable.should respond_to(:opts)
    end
  
    it 'should have an #uri attribute after creation' do
      requestable.should respond_to(:uri)
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
  
  context :request do
    
    include RequestableHelper
    
    it 'should send a get to itself' do
      expected_response = {:status_code => 200}
      requestable.should_receive(:get).
        with('/blah', {:id=>1}).
        and_return(expected_response)
      requestable.request('/blah', :id=>1).should == expected_response
    end
    
    it 'should raise an error if the status_code is not 200' do
      expected_response = {:status_code => 503}
      requestable.should_receive(:get).
        with('/blah', {:id=>1}).
        and_return(expected_response)
      lambda{
        requestable.request('/blah', :id=>1)
      }.should raise_error
    end
    
    it 'should send a post to itself if data is supplied' do
      expected_response = {:status_code => 200}
      my_data = "<commit/>"
      post_headers = {"Content-Type"=>"text/xml; charset=utf-8"}
      requestable.should_receive(:post).
        with('/blah', my_data, {:id=>1}, post_headers).
        and_return(expected_response)
      requestable.request('/blah', {:id=>1}, my_data).should == expected_response
    end
    
    it 'should send a post to itself when :method=>:post is set even if no POST data is supplied' do
      expected_response = {:status_code => 200}
      post_headers = {"Content-Type"=>"application/x-www-form-urlencoded"}
      requestable.should_receive(:post).
        with('/blah', "", {}, post_headers).
        and_return(expected_response)
      requestable.request('/blah', {}, :method => :post).should == expected_response
    end
    
  end
  
end