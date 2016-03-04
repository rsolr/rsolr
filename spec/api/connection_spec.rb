require 'spec_helper'
require 'base64'

describe "RSolr::Connection" do

  context "setup_raw_request" do
    it "should set the correct request parameters" do
      c = RSolr::Connection.new
      base_url = "http://localhost:8983/solr"
      client = RSolr::Client.new c, :url => base_url
      req = c.send :setup_raw_request, {:headers => {"content-type" => "text/xml"}, :method => :get, :uri => URI.parse(base_url + "/select?q=*:*")}
      expect(req.path).to eq("/solr/select?q=*:*")
      headers = {}
      req.each_header{|k,v| headers[k] = v}
      expect(headers).to eq({"content-type"=>"text/xml"})
    end
  end

  context "when the connection is refused" do
    subject { RSolr::Connection.new }

    it "raises a custom exception" do
      http_stub = double("Net:HTTP")
      allow(http_stub).to receive(:request).and_raise(Errno::ECONNREFUSED)

      allow(subject).to receive(:setup_raw_request) { http_stub }
      allow(subject).to receive(:http) { Net::HTTP.new("localhost", 80) }

      expect { subject.execute(nil, {}) }.to raise_error(RSolr::Error::ConnectionRefused)
    end
  end

  context "read timeout configuration" do
    let(:client) { double.as_null_object }

    let(:http) { double(Net::HTTP).as_null_object }

    subject { RSolr::Connection.new }

    before do
      allow(Net::HTTP).to receive(:new) { http }
    end

    it "should configure Net:HTTP read_timeout" do
      expect(http).to receive(:read_timeout=).with(42)
      subject.execute client, {:uri => URI.parse("http://localhost/some_uri"), :method => :get, :read_timeout => 42}
    end

    it "should use Net:HTTP default read_timeout if not specified" do
      expect(http).not_to receive(:read_timeout=)
      subject.execute client, {:uri => URI.parse("http://localhost/some_uri"), :method => :get}
    end
  end

  context "open timeout configuration" do
    let(:client) { double.as_null_object }

    let(:http) { double(Net::HTTP).as_null_object }

    subject { RSolr::Connection.new }

    before do
      allow(Net::HTTP).to receive(:new) { http }
    end

    it "should configure Net:HTTP open_timeout" do
      expect(http).to receive(:open_timeout=).with(42)
      subject.execute client, {:uri => URI.parse("http://localhost/some_uri"), :method => :get, :open_timeout => 42}
    end

    it "should use Net:HTTP default open_timeout if not specified" do
      expect(http).not_to receive(:open_timeout=)
      subject.execute client, {:uri => URI.parse("http://localhost/some_uri"), :method => :get}
    end
  end

  context "proxy configuration" do
    let(:client) { double.as_null_object }

    let(:http) { double(Net::HTTP).as_null_object }

    let(:uri) { URI.parse("http://localhost/some_url") }
    let(:proxy) { URI.parse("http://my.proxy/") }

    subject { RSolr::Connection.new }

    it "should use the default if no proxy is provided" do
      expect(Net::HTTP).to receive(:new).with(uri.host, uri.port) { http }
      subject.execute client, { :uri => uri, :method => :get }
    end

    it "should use the proxy if one is provided" do
      expect(Net::HTTP).to receive(:Proxy).with(proxy.host, proxy.port, nil, nil) { http }
      subject.execute client, { :uri => uri, :proxy => proxy, :method => :get }
    end

    it "should not use a proxy if proxy setting is false" do
      expect(Net::HTTP).to receive(:new).with(uri.host, uri.port, nil) { http }
      subject.execute client, { :uri => uri, :proxy => false, :method => :get }
    end
  end

  context "connection refused" do
    let(:client) { double.as_null_object }

    let(:http) { double(Net::HTTP).as_null_object }
    let(:request_context) {
      {:uri => URI.parse("http://localhost/some_uri"), :method => :get, :open_timeout => 42}
    }
    subject { RSolr::Connection.new }

    before do
      allow(Net::HTTP).to receive(:new) { http }
    end

    it "should configure Net:HTTP open_timeout" do
      skip "doesn't work with ruby 1.8" if RUBY_VERSION < "1.9"
      expect(http).to receive(:request).and_raise(Errno::ECONNREFUSED)
      expect {
        subject.execute client, request_context
      }.to raise_error(Errno::ECONNREFUSED, /#{request_context}/)
    end
  end

  describe "basic auth support" do
    let(:http) { double(Net::HTTP).as_null_object }

    before do
      allow(Net::HTTP).to receive(:new) { http }
    end

    it "sets the authorization header" do
      expect(http).to receive(:request) do |request|
        expect(request.fetch('authorization')).to eq("Basic #{Base64.encode64("joe:pass")}".strip)
        double(Net::HTTPResponse).as_null_object
      end
      RSolr::Connection.new.execute nil, :uri => URI.parse("http://joe:pass@localhost:8983/solr"), :method => :get
    end
  end
end
