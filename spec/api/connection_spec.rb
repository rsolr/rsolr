require 'spec_helper'

describe "RSolr::Connection" do

  context "self.valid_methods" do
    it "should return the valid http verbs" do
      RSolr::Connection.valid_methods.should == [:get, :post, :head]
    end
  end

end