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
    
  end
  
  
end