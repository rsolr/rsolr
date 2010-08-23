require 'spec_helper'

describe "RSolr::Requestable" do
  
  def requestable
    Object.new.extend RSolr::Requestable
  end
  
  def responsable
    Object.new.extend RSolr::Responsable
  end
  
  context "Responsable.adapt_response" do
    
    it 'should not try to evaluate ruby when the :qt is not :ruby' do
      body = '{:time=>"NOW"}'
      result = responsable.adapt_response({:params=>{}}, {:status => 200, :body => body, :headers => {}})
      result.should be_a(String)
      result.should == body
    end
    
    it 'should evaluate ruby responses when the :wt is :ruby' do
      body = '{:time=>"NOW"}'
      result = responsable.adapt_response({:params=>{:wt=>:ruby}}, {:status => 200, :body => body, :headers => {}})
      result.should be_a(Hash)
      result.should == {:time=>"NOW"}
    end
    
    it "ought raise a RSolr::Error::InvalidRubyResponse when the ruby is indeed frugged" do
      lambda {
        responsable.adapt_response({:params=>{:wt => :ruby}}, {:status => 200, :body => "<woops/>", :headers => {}})
      }.should raise_error RSolr::Error::InvalidRubyResponse
    end
  
  end

  context "build_request" do
    
    it 'should return a request context array' do
      result = requestable.build_request 'select', :method => :post, :params => {:q=>'test', :fq=>[0,1]}, :data => "data", :headers => {}
      [/fq=0/, /fq=1/, /q=test/, /wt=ruby/].each do |pattern|
        result[:query].should match pattern
      end
      result[:data].should == "data"
      result[:headers].should == {}
    end
    
    it "should set the Content-Type header to application/x-www-form-urlencoded if a hash is passed in to the data arg" do
      result = requestable.build_request 'select', :method => :post, :data => {:q=>'test', :fq=>[0,1]}, :headers => {}
      result[:query].should == "wt=ruby"
      [/fq=0/, /fq=1/, /q=test/].each do |pattern|
        result[:data].should match pattern
      end
      result[:data].should_not match /wt=ruby/
      result[:headers].should == {"Content-Type" => "application/x-www-form-urlencoded"}
    end
    
  end
  
end