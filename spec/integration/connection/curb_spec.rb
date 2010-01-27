describe RSolr::Connection::Curb do
  
  module Helpers
    def new_curb
      RSolr::Client.new(RSolr::Connection::Curb.new)
    end
  end
  
  context "initialize" do
    extend Helpers
    solr = new_curb
    solr.connection.send(:connection).class.should == Curl::Easy
    solr.connection.opts.should == {:url => 'http://127.0.0.1:8983/solr'}
  end
  
  context "select" do
    
  end
  
end