require 'spec_helper'
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
      result = client.send(:adapt_response, {:params=>{}}, {:status => 200, :body => body, :headers => {}})
      result.should be_a(String)
      result.should == body
    end
    
    it 'should evaluate ruby responses when the :wt is :ruby' do
      body = '{:time=>"NOW"}'
      result = client.send(:adapt_response, {:params=>{:wt=>:ruby}}, {:status => 200, :body => body, :headers => {}})
      result.should be_a(Hash)
      result.should == {:time=>"NOW"}
    end
    
    ["nil", :ruby].each do |wt|
      it "should return an object that responds to :request and :response when :wt == #{wt}" do
        req = {:params=>{:wt=>wt}}
        res = {:status => 200, :body => "", :headers => {}}
        result = client.send(:adapt_response, req, res)
        result.request.should == req
        result.response.should == res
      end
    end
    
    it "ought raise a RSolr::Error::InvalidRubyResponse when the ruby is indeed frugged" do
      lambda {
        client.send(:adapt_response, {:params=>{:wt => :ruby}}, {:status => 200, :body => "<woops/>", :headers => {}})
      }.should raise_error RSolr::Error::InvalidRubyResponse
    end
    
  end
  
  context "build_request" do
    include ClientHelper
    it 'should return a request context array' do
      result = client.build_request 'select', :params => {:q=>'test', :fq=>[0,1]}, :data => "data", :headers => {}
      [/fq=0/, /fq=1/, /q=test/, /wt=ruby/].each do |pattern|
        result[:query].should match pattern
      end
      result[:data].should == "data"
      result[:headers].should == {}
    end
    it "should set the Content-Type header to application/x-www-form-urlencoded if a hash is passed in to the data arg" do
      result = client.build_request 'select', :data => {:q=>'test', :fq=>[0,1]}, :headers => {}
      result[:query].should == "wt=ruby"
      [/fq=0/, /fq=1/, /q=test/].each do |pattern|
        result[:data].should match pattern
      end
      result[:data].should_not match /wt=ruby/
      result[:headers].should == {"Content-Type" => "application/x-www-form-urlencoded"}
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
    it "should forward these method calls the #connection object" do
      [:get, :post, :head].each do |meth|
        client.connection.should_receive(meth).
            and_return({:status => 200, :body => "{}", :headers => {}})
        client.send_request '', :method => meth, :params => {}, :data => nil, :headers => {}
      end
    end
    it "should extend any exception raised by the #connection object with a RSolr::Error::SolrContext" do
      client.connection.should_receive(:get).
          and_raise(RuntimeError)
      lambda {
        client.send_request '', :method => :get
      }.should raise_error(RuntimeError){|error|
        error.should be_a(RSolr::Error::SolrContext)
        error.should respond_to(:request)
        error.request.keys.should include(:path, :client, :method, :query, :data, :headers, :params)
      }
    end
    it "should raise an Http error if the response status code aint right" do
      client.connection.should_receive(:get).
        and_return({:status => 400, :body => "", :headers => {}})
      lambda{
        client.send_request '', :method => :get
      }.should raise_error(RSolr::Error::Http) {|error|
        error.should be_a(RSolr::Error::Http)
        error.should respond_to(:request)
        error.should respond_to(:response)
      }
    end
  end
  
  context "post" do
    include ClientHelper
    it "should pass the expected params to the connection's #post method" do
      client.connection.should_receive(:post).
        with(
          :params=>{:wt=>:ruby},
          :query=>"wt=ruby",
          :path => "update",
          :data=>"the data",
          :method=>:post,
          :headers=>{"Content-Type"=>"text/plain"},
          :client=>client
        ).
          and_return(:status => 200, :body => "", :headers => {})
      client.post "update", :data => "the data", :headers => {"Content-Type" => "text/plain"}
    end
  end
  
  context "xml" do
    include ClientHelper
    it "should return an instance of RSolr::Xml::Generator" do
      client.xml.should be_a RSolr::Xml::Generator
    end
  end
  
  context "add" do
    include ClientHelper
    it "should send xml to the connection's #post method" do
      client.connection.should_receive(:post).
        with(
          :client => client,
          :path => "update",
          :data => "<xml/>",
          :headers => {"Content-Type"=>"text/xml"},
          :method => :post,
          :query => "wt=ruby",
          :params => {:wt=>:ruby}
        ).
          and_return({:status => 200, :body => "", :headers => {}})
      # the :xml attr is lazy loaded... so load it up first
      client.xml
      client.xml.should_receive(:add).
        with({:id=>1}, :commitWith=>10).
          and_return("<xml/>")
      client.add({:id=>1}, :add_attrs => {:commitWith=>10})
    end
  end
  
  context "update" do
    include ClientHelper
    it "should send data to the connection's #post method" do
      client.connection.should_receive(:post).
        with(
          :client => client,
          :path => "update",
          :data => "<optimize/>",
          :headers => {"Content-Type"=>"text/xml"},
          :method => :post,
          :query => "wt=ruby",
          :params => {:wt=>:ruby}
        ).
          and_return({:status => 200, :body => "", :headers => {}})
      client.update(:data => "<optimize/>")
    end
  end
  
  context "post based helper methods:" do
    include ClientHelper
    [:commit, :optimize, :rollback].each do |meth|
      it "should send a #{meth} message to the connection's #post method" do
        client.connection.should_receive(:post).
          with(
            :client => client,
            :path => "update",
            :data => "<?xml version=\"1.0\" encoding=\"UTF-8\"?><#{meth}/>",
            :headers => {"Content-Type"=>"text/xml"},
            :method => :post,
            :query => "wt=ruby",
            :params => {:wt=>:ruby}
          ).
            and_return({:status => 200, :body => "", :headers => {}})
        client.send meth
      end
    end
  end
  
  context "delete_by_id" do
    include ClientHelper
    it "should send data to the connection's #post method" do
      client.connection.should_receive(:post).
        with(
          :client => client,
          :path => "update",
          :data => "<?xml version=\"1.0\" encoding=\"UTF-8\"?><delete><id>1</id></delete>",
          :headers => {"Content-Type"=>"text/xml"},
          :method => :post,
          :query => "wt=ruby",
          :params => {:wt=>:ruby}
        ).
          and_return({:status => 200, :body => "", :headers => {}})
      client.delete_by_id 1
    end
  end
  
  context "delete_by_query" do
    include ClientHelper
    it "should send data to the connection's #post method" do
      client.connection.should_receive(:post).
        with(
          :client => client,
          :path => "update",
          :data => "<?xml version=\"1.0\" encoding=\"UTF-8\"?><delete><query fq=\"category:&quot;trash&quot;\"/></delete>",
          :headers => {"Content-Type"=>"text/xml"},
          :method => :post,
          :query => "wt=ruby",
          :params => {:wt=>:ruby}
        ).
          and_return({:status => 200, :body => "", :headers => {}})
      client.delete_by_query :fq => "category:\"trash\""
    end
  end
  
end