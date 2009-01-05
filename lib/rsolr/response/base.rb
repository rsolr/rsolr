# default/base response object
# This is where the ruby "eval" happens
# So far, all response classes extend this
class RSolr::Response::Base
  
  # the object that contains the original :body, :params, full solr :query, post :data etc.
  attr_reader :input
  
  attr_reader :data, :header, :params, :status, :query_time
  
  def initialize(input)
    input = {:body=>input} if input.is_a?(String)
    @input = input
    @data = Kernel.eval(input[:body]).to_mash
    @header = @data[:responseHeader]
    @params = @header[:params]
    @status = @header[:status]
    @query_time = @header[:QTime]
  end
  
  def ok?
    self.status == 0
  end
  
end