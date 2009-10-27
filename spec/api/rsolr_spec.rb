describe RSolr do
  
  it 'should respond to #connect' do
    RSolr.should respond_to(:connect)
  end
  
  it 'can accept options without connection type' do
    lambda{RSolr.connect :url=>'http://localhost:8983/solr'}.should_not raise_error
  end

  it 'can accept :http for a connection type symbol' do
    lambda{RSolr.connect :http}.should_not raise_error
  end

  it 'will raise an error if trying to using a :direct when not running in jruby' do
    lambda {
      RSolr.connect :direct
    }.should raise_error(RuntimeError) unless jruby?
  end

  it 'will not raise an error if trying to using a :direct when running in jruby' do
    lambda {
      RSolr.connect :direct
    }.should_not raise_error(RuntimeError) if jruby?
  end

  it 'should raise an error if an invalid connection type is specified' do
    lambda { RSolr.connect :blah! }.should raise_error(RuntimeError)
  end

  it 'should create an instance of RSolr::Connection::HTTP as the #adapter' do
    expected_class = RSolr::Connection::NetHttp
    RSolr.connect.adapter.should be_a(expected_class)
    RSolr.connect(:http).adapter.should be_a(expected_class)
    RSolr.connect(:url=>'blah').adapter.should be_a(expected_class)
  end

  it 'should create an instance of RSolr::Connection::Direct as the #adapter' do
    RSolr.connect(:direct, {}).adapter.should be_a(RSolr::Connection::Direct) if jruby?
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