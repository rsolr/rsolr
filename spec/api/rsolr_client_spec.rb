describe "RSolr::Client" do
  
  module ClientHelper
    def client
      @client ||= (
        connection = RSolr::Http.new URI.parse("http://localhost:9999/solr")
        RSolr::Client.new(connection)
      )
    end
  end
  
  context "initialize" do
    it "should accept whatevs and set it as the @connection" do
      RSolr::Client.new(:whatevs).connection.should == :whatevs
    end
  end
  
  context "adapt_response" do
    
    include ClientHelper
    
    it 'should not try to evaluate ruby when the :qt is not :ruby' do
      body = '{:time=>"NOW"}'
      result = client.send(:adapt_response, {:params=>{}}, {:body => body})
      result.should be_a(String)
      result.should == body
    end
    
    it 'should evaluate ruby responses when the :wt is :ruby' do
      body = '{:time=>"NOW"}'
      result = client.send(:adapt_response, {:params=>{:wt=>:ruby}}, {:body=>body})
      result.should be_a(Hash)
      result.should == {:time=>"NOW"}
    end
    
    ["nil", :ruby].each do |wt|
      it "should return an object that responds to :request and :response when :wt == #{wt}" do
        req = {:params=>{:wt=>wt}}
        res = {:body=>""}
        result = client.send(:adapt_response, req, res)
        result.request.should == req
        result.response.should == res
      end
    end
    
    it "ought raise a RSolr::Error::InvalidRubyResponse when the ruby is indeed frugged" do
      lambda {
        client.send(:adapt_response, {:params=>{:wt => :ruby}}, {:body => "<woops/>"})
      }.should raise_error RSolr::Error::InvalidRubyResponse
    end
    
  end
  
  context "build_request" do
    include ClientHelper
    it 'should build a request context array' do
      result = client.build_request 'select', {:q=>'test', :fq=>[0,1]}, "data", headers = {}
      result[0].to_s.should == "select?q=test&fq=0&fq=1"
      result[1].should == "data"
      result[2].should == headers
    end
    it 'should convert a data Hash to a solr query string and set the form-urlencoded headers' do
      result = client.build_request 'select', nil, {:q=>'test', :fq=>[0,1]}, headers = {}
      result[0].to_s.should == "select"
      result[1].should == "q=test&fq=0&fq=1"
      result[2].should == headers
    end
  end
  
  context "map_params" do
    include ClientHelper
    it "should return a hash if nil is passed in" do
      client.map_params(nil).should == {:wt => :ruby}
    end
    it "should set the :wt to ruby if blank" do
      r = client.map_params({:q=>"q"})
      r[:q].should == "q"
      r[:wt].should == :ruby
    end
    it "should not override the :wt to ruby if set" do
      r = client.map_params({:q=>"q", :wt => :json})
      r[:q].should == "q"
      r[:wt].should == :json
    end
  end
  
  context "send_request" do
    include ClientHelper
    it "should forward method calls the #connection object" do
      [:get, :post, :head].each do |meth|
        client.connection.should_receive(meth).
            and_return({:status => 200})
        client.send_request meth, '', {}, nil, {}
      end
    end
    it "should extend any exception raised by the #connection object with a RSolr::Error::SolrContext" do
      client.connection.should_receive(:get).
          and_raise(RuntimeError)
      lambda {
        client.send_request :get, '', {}, nil, {}
      }.should raise_error(RuntimeError){|error|
        error.should be_a(RSolr::Error::SolrContext)
        error.should respond_to(:request)
        error.request.keys.should include(:connection, :method, :uri, :data, :headers, :params)
      }
    end
    it "should raise an Http error if the response status code aint right" do
      client.connection.should_receive(:get).
        and_return({:status_code => 404})
      lambda{
        client.send_request :get, '', {}, nil, {}
      }.should raise_error(RSolr::Error::Http) {|error|
        error.should be_a(RSolr::Error::Http)
        error.should respond_to(:request)
        error.should respond_to(:response)
      }
    end
  end
  
  context "post" do
    
  end
  
  context "head" do
    
  end
  
  context "xml" do
    
  end
  
  context "add" do
    
  end
  
  context "update" do
    
  end
  
  context "commit" do
    
  end
  
  context "optimize" do
    
  end
  
  context "rollback" do
    
  end
  
  context "delete_by_id" do
    
  end
  
  context "delete_by_query" do
    
  end
  
end