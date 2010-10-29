require 'spec_helper'
describe "RSolr::Pagination" do
  context "calculate_start_and_rows" do
    it "should return an array with 2 ints" do
      values = RSolr::Pagination.calculate_start_and_rows 2, 10
      values[0].should == 10
      values[1].should == 10
    end
    it "should handle string values" do
      values = RSolr::Pagination.calculate_start_and_rows "1", "22"
      values[0].should == 0
      values[1].should == 22
    end
  end
  context "build_paginated_request" do
    it "should create the proper solr params and query string" do
      c = RSolr::Client.new(nil, {}).extend(RSolr::Pagination::Client)
      r = c.build_paginated_request 3, 25, "select", {:params => {:q => "test"}}
      r[:page].should == 3
      r[:per_page].should == 25
      r[:params][:start].should == 50
      r[:params][:rows].should == 25
      r[:uri].query.should =~ /rows=25/
      r[:uri].query.should =~ /start=50/
    end
  end
  context "paginate" do
    it "should build a paginated request context and call execute" do
      c = RSolr::Client.new(nil, {}).extend(RSolr::Pagination::Client)
      c.should_receive(:execute).with(hash_including({
        :page => 1,
        :per_page => 10,
        :params => {
          :rows => 10,
          :start => 0,
          :wt => :ruby
        }
      }))
      c.paginate 1, 10, "select"
    end
  end
end