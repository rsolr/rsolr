require 'spec_helper'
describe "RSolr::Pagination" do
  context "build_paginated_request" do
    it "should create the proper solr params and query string" do
      c = RSolr::Client.new(nil, {})#.extend(RSolr::Pagination::Client)
      r = c.build_paginated_request 3, 25, "select", {:params => {:q => "test"}}
      #r[:page].should == 3
      #r[:per_page].should == 25
      r[:params]["start"].should == 50
      r[:params]["rows"].should == 25
      r[:uri].query.should =~ /rows=25/
      r[:uri].query.should =~ /start=50/
    end
  end
  context "paginate" do
    it "should build a paginated request context and call execute" do
      c = RSolr::Client.new(nil, {})#.extend(RSolr::Pagination::Client)
      c.should_receive(:execute).with(hash_including({
        #:page => 1,
        #:per_page => 10,
        :params => {
          "rows" => 10,
          "start" => 0,
          :wt => :ruby
        }
      }))
      c.paginate 1, 10, "select"
    end
  end
end