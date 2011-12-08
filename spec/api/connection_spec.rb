require 'spec_helper'

describe "RSolr::Connection" do

  before do
    @solr = "http://localhost:8983/solr"
    @conn = RSolr::Connection.new
  end

  it "Should handle a raw request" do
    client = RSolr::Client.new @conn, :url => @solr
    req = @conn.send :setup_raw_request, {
      :headers => {"content-type" => "text/xml"}, 
      :method => :get, 
      :uri => URI.parse(@solr + "/select?q=*:*")}
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
  
end
