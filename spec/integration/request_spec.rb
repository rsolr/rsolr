describe "Requests" do
  
  it "should raise a connection error when using a funked up url" do
    lambda{
      funked_rsolr = RSolr.connect "http://zxcvbnmasdfghjk:1234/solr/"
      funked_rsolr.get "admin/ping"
    }.should raise_error(Errno::ECONNREFUSED)
  end
  
  it "should return results from admin/ping" do
    response = rsolr.get 'admin/ping'
    
  end
  
end