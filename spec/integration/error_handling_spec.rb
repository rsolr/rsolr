require 'spec_helper'
require 'webmock/rspec'

RSpec.describe "error handling" do

  context "error wrapping" do
    before(:all) do
        stub_request(:any, %r{localhost:65432}).to_raise(Errno::ECONNREFUSED)
    end
    subject { RSolr.connect url: "http://localhost:65432/solr/basic_configs/"}

    it "wraps connection errors" do
      expect { subject.head('admin/ping') }.to raise_error RSolr::Error::ConnectionRefused
    end
  end
end
