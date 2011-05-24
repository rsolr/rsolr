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
  
end