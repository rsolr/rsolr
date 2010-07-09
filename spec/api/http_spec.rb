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