require 'spec_helper'
describe "RSolr" do
  
  it "has a version that can be read via #version or VERSION" do
    RSolr.version.should == RSolr::VERSION
  end
  
  it "can escape" do
    RSolr.should be_a(RSolr::Char)
    RSolr.escape("this string").should == "this\\ string"
  end
  
  context "connect" do
    it "should return a RSolr::Client instance" do
      RSolr.connect.should be_a(RSolr::Client)
    end
  end
  
end