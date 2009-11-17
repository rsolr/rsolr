describe RSolr do
  
  it 'should respond to #connect' do
    RSolr.should respond_to(:connect)
  end
  
  it 'can accept options without connection type' do
    lambda{RSolr.connect :url=>'http://localhost:8983/solr'}.should_not raise_error
  end

  it 'can only accept an options hash for a the #connect method' do
    lambda{RSolr.connect :blah}.should raise_error
  end
  
  it 'should create an instance of RSolr::Connection::HTTP as the #connection' do
    expected_class = RSolr::Connection::NetHttp
    RSolr.connect.connection.should be_a(expected_class)
    RSolr.connect(:url=>'blah').connection.should be_a(expected_class)
  end
  
  if jruby?
    
    it 'should not fail when creating a direct connection' do
      lambda{
        RSolr.direct_connect({})
      }.should_not raise_error
    end
    
    it 'should create an instance of RSolr::Connection::Direct when using #direct_connect' do
      rsolr = RSolr.direct_connect({})
      rsolr.should be_a RSolr::Client
      rsolr.connection.should be_a(RSolr::Connection::Direct)
      rsolr.connection.close
    end
    
    it 'should create an instance of RSolr::Connection::Direct when using #direct_connect and close when using a block' do
      RSolr.direct_connect({}) do |rsolr|
        rsolr.should be_a RSolr::Client
        rsolr.connection.should be_a(RSolr::Connection::Direct)
      end
    end
    
  else
    
    it 'should respond_to and attempt to create a direct connection, and fail!' do
      lambda{ RSolr.direct_connect({}) }.should raise_error(RuntimeError, 'JRuby Required')
    end
    
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