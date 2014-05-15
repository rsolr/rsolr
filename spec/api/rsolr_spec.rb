require 'spec_helper'
describe "RSolr" do
  
  it "has a version that can be read via #version or VERSION" do
    expect(RSolr.version).to eq(RSolr::VERSION)
  end
  
  it "can escape" do
    expect(RSolr).to be_a(RSolr::Char)
    expect(RSolr.escape("this string")).to eq("this\\ string")
  end
  
  context "connect" do
    it "should return a RSolr::Client instance" do
      expect(RSolr.connect).to be_a(RSolr::Client)
    end
  end
  
end