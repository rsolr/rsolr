describe "Solr servlet error handling" do
  
  it "should raise a RSolr::Request which contains the http request context" do
    s = RSolr.connect
    begin
      s.select :qt => 'standard'
    rescue RSolr::RequestError
      
    end
  end
  
end