require 'spec_helper'
require 'webmock/rspec'

RSpec.describe "Solr basic_configs" do

  context "basic configs" do
    subject { RSolr.connect url: "http://localhost:8983/solr/basic_configs/"}
    before(:each) do
      stub_request(:head, %r{localhost:8983}).to_return(status: 200, body: "", headers: {})

    end
    
describe "HEAD admin/ping" do
      it "should not raise an exception" do
        expect { subject.head('admin/ping') }.not_to raise_error
      end

      it "should not have a body" do
        expect(subject.head('admin/ping')).to be_kind_of RSolr::HashWithResponse
      end
    end
  end

  context "error handling" do
    before(:all) do
        stub_request(:any, %r{localhost:65432}).to_raise(Errno::ECONNREFUSED)
    end
    subject { RSolr.connect url: "http://localhost:65432/solr/basic_configs/"}

    it "wraps connection errors" do
      expect { subject.head('admin/ping') }.to raise_error RSolr::Error::ConnectionRefused
    end
  end
end
