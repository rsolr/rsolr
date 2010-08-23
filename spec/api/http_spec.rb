require 'spec_helper'
describe "RSolr::Http" do
  it "Should be an RSolr::Requestable) and implement an execute method" do
    http = RSolr::Http.new
    http.should be_a(RSolr::Requestable)
    http.should respond_to(:execute)
  end
  
  context "execute" do
    it "should require a request_context hash" do
      http = RSolr::Http.new
      lambda {
        http.execute
      }.should raise_error(ArgumentError)
    end
  end
  
  # it "should raise an Http error if the response status code aint right" do
  #   client.connection.should_receive(:get).
  #     and_return({:status => 400, :body => "", :headers => {}})
  #   lambda{
  #     client.send_request '', :method => :get
  #   }.should raise_error(RSolr::Error::Http) {|error|
  #     error.should be_a(RSolr::Error::Http)
  #     error.should respond_to(:request)
  #     error.should respond_to(:response)
  #   }
  # end
end