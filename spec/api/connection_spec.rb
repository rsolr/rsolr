require 'spec_helper'
require 'base64'

describe "RSolr::Connection" do
  
  context "setup_raw_request" do
    c = RSolr::Connection.new
    base_url = "http://localhost:8983/solr"
    client = RSolr::Client.new c, :url => base_url
    req = c.send :setup_raw_request, {:headers => {"content-type" => "text/xml"}, :method => :get, :uri => URI.parse(base_url + "/select?q=*:*")}
    req.path.should == "/solr/select?q=*:*"
    headers = {}
    req.each_header{|k,v| headers[k] = v}
    headers.should == {"content-type"=>"text/xml"}
  end

  context "read timeout configuration" do
    let(:client) { mock.as_null_object }

    let(:http) { mock(Net::HTTP).as_null_object }

    subject { RSolr::Connection.new } 

    before do
      Net::HTTP.stub(:new) { http }
    end

    it "should configure Net:HTTP read_timeout" do
      http.should_receive(:read_timeout=).with(42)
      subject.execute client, {:uri => URI.parse("http://localhost/some_uri"), :method => :get, :read_timeout => 42}
    end

    it "should use Net:HTTP default read_timeout if not specified" do
      http.should_not_receive(:read_timeout=)
      subject.execute client, {:uri => URI.parse("http://localhost/some_uri"), :method => :get}
    end
  end

  context "open timeout configuration" do
    let(:client) { mock.as_null_object }

    let(:http) { mock(Net::HTTP).as_null_object }

    subject { RSolr::Connection.new } 

    before do
      Net::HTTP.stub(:new) { http }
    end

    it "should configure Net:HTTP open_timeout" do
      http.should_receive(:open_timeout=).with(42)
      subject.execute client, {:uri => URI.parse("http://localhost/some_uri"), :method => :get, :open_timeout => 42}
    end

    it "should use Net:HTTP default open_timeout if not specified" do
      http.should_not_receive(:open_timeout=)
      subject.execute client, {:uri => URI.parse("http://localhost/some_uri"), :method => :get}
    end
  end

  context "connection refused" do
    let(:client) { mock.as_null_object }

    let(:http) { mock(Net::HTTP).as_null_object }
    let(:request_context) {
      {:uri => URI.parse("http://localhost/some_uri"), :method => :get, :open_timeout => 42}
    }
    subject { RSolr::Connection.new } 

    before do
      Net::HTTP.stub(:new) { http }
    end

    it "should configure Net:HTTP open_timeout" do
      http.should_receive(:request).and_raise(Errno::ECONNREFUSED)
      lambda {
        subject.execute client, request_context
      }.should raise_error(Errno::ECONNREFUSED, /#{request_context}/)
    end
  end
  
  describe "basic auth support" do
    let(:http) { mock(Net::HTTP).as_null_object }
    
    before do
      Net::HTTP.stub(:new) { http }
    end
    
    it "sets the authorization header" do
      http.should_receive(:request) do |request|
        request.fetch('authorization').should == "Basic #{Base64.encode64("joe:pass")}".strip
        mock(Net::HTTPResponse).as_null_object
      end
      RSolr::Connection.new.execute nil, :uri => URI.parse("http://joe:pass@localhost:8983/solr"), :method => :get
    end
  end
end
