require 'spec_helper'
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
  
end
