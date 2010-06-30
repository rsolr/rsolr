require 'spec_helper'
describe "RSolr class methods" do
  
  it "should parse these here options" do
    result = RSolr.parse_options "http://localhost:8983/solr/blah", :proxy => "http://qtpaglzvm.com"
    result[0].should be_a(URI)
    result[1].should be_a(Hash)
    result[1][:proxy].should be_a(URI)
  end
  
  it "should not create a URI instance for :proxy => nil" do
    result = RSolr.parse_options "http://localhost:8983/solr/blah"
    result[0].should be_a(URI)
    result[1].should == {:proxy => nil}
  end
  
end