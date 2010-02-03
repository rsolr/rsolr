describe RSolr do
  
  it 'should respond to #connect' do
    RSolr.should respond_to(:connect)
  end
  
  it 'can accept options without connection type' do
    lambda{RSolr.connect :url=>'http://localhost:8983/solr'}.should_not raise_error
  end
  
  # it 'will throw an Adaptable::Invalid if the connection type is not valid' do
  #   lambda{RSolr.connect :blah}.should raise_error(RSolr::Adaptable::Invalid)
  # end
  
  it 'should create an instance of RSolr::Connection::NetHttp as the #connection' do
    expected_class = RSolr::Connection::NetHttp
    RSolr.connect.connection.should be_a(expected_class)
    RSolr.connect(:url=>'blah').connection.should be_a(expected_class)
  end
  
  it 'should have an escape method' do
    RSolr.should respond_to(:escape)
  end
  
  it "should escape properly" do
    RSolr.escape('Trying & % different "characters" here!').should == "Trying\\ \\&\\ \\%\\ different\\ \\\"characters\\\"\\ here\\!"
  end
  
  it 'should escape' do
    expected = "http\\:\\/\\/lucene\\.apache\\.org\\/solr"
    RSolr.escape("http://lucene.apache.org/solr").should == expected
  end
  
end