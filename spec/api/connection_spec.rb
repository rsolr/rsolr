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

  it "handle no proxy passed through" do
    with_proxy_env nil do
      req = @conn.send :http, URI::parse(@solr)
      req.proxyaddr.should == nil 
      req.proxyport.should == nil 
    end
  end

  it "handle a proxy string passed through" do
    with_proxy_env nil do
      proxy = "http://www.duncanproxy.com"
      req = @conn.send :http, URI::parse(@solr), proxy
      req.proxyaddr.should == "www.duncanproxy.com" 
      req.proxyport.should == 80 
    end
  end

  it "handle a proxy with username and password" do
    with_proxy_env nil do
      proxy = "http://duncan:robertson@www.duncanproxy.com"
      req = @conn.send :http, URI::parse(@solr), proxy
      req.proxyaddr.should == "www.duncanproxy.com" 
      req.proxyport.should == 80 
      req.proxy_user.should == "duncan" 
      req.proxy_pass.should == "robertson" 
    end
  end

  it "handle http_proxy environment set" do
    with_proxy_env "http://duncan.proxy.com:80" do
      req = @conn.send :http, URI::parse(@solr)
      req.proxyaddr.should == "duncan.proxy.com" 
      req.proxyport.should == 80 
    end
  end

  it "handle http_proxy environment set and proxy passed in" do
    with_proxy_env "http://duncan.proxy.com:80" do
      proxy = "http://www.duncanproxy.com:8080"
      req = @conn.send :http, URI::parse(@solr), proxy
      req.proxyaddr.should == "www.duncanproxy.com" 
      req.proxyport.should == 8080 
    end
  end
  
end
