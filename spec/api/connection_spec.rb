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

    subject { RSolr::Connection.new } 

    it "should configure Net:HTTP read_timeout" do
      subject.execute client, {:uri => URI.parse("http://localhost/some_uri"), :method => :get, :read_timeout => 42}
      http = subject.instance_variable_get(:@http)
      http.read_timeout.should == 42
    end

    it "should use Net:HTTP default read_timeout if not specified" do
      subject.execute client, {:uri => URI.parse("http://localhost/some_uri"), :method => :get}
      http = subject.instance_variable_get(:@http)
      http.read_timeout.should == 60
    end
  end

  context "open timeout configuration" do
    let(:client) { mock.as_null_object }

    subject { RSolr::Connection.new } 

    it "should configure Net:HTTP open_timeout" do
      subject.execute client, {:uri => URI.parse("http://localhost/some_uri"), :method => :get, :open_timeout => 42}
      http = subject.instance_variable_get(:@http)
      http.open_timeout.should == 42
    end

    it "should use Net:HTTP default open_timeout if not specified" do
      subject.execute client, {:uri => URI.parse("http://localhost/some_uri"), :method => :get}
      http = subject.instance_variable_get(:@http)
      http.open_timeout.should == nil
    end
  end
  
end
