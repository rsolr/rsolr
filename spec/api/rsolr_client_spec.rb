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
  
end