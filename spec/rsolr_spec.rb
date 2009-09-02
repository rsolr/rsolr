require 'helper'

describe RSolr do
  
  context 'the #connect method' do
    
    it 'should exist' do
      RSolr.should respond_to(:connect)
    end
    
    it 'should return an RSolr::Connection object' do
      RSolr.connect.should be_a(RSolr::Connection::Base)
    end
    
  end
  
  context "the #escape method" do
    
    it "should exist" do
      RSolr.should respond_to(:escape)
    end
    
    it "should escape properly" do
      RSolr.escape('Trying & % different "characters" here!').should == "Trying\\ \\&\\ \\%\\ different\\ \\\"characters\\\"\\ here\\!"
    end
    
  end
  
end