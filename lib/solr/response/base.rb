# default/base response object
# This is where the ruby "eval" happens
# So far, all response classes extend this
class Solr::Response::Base
  
  attr_reader :source
  
  attr_reader :raw_response, :data, :header, :params, :status, :query_time
  
  def initialize(data)
    if data.is_a?(Hash) and data.has_key?(:body)
      @data = Kernel.eval(data[:body])
      @source = data
    else
      if data.is_a?(String)
        @raw_response = data
        @data = Kernel.eval(@raw_response)
      elsif data.is_a?(Hash)
        @data = data
      end
    end
    @header = @data['responseHeader']
    @params = @header['params']
    @status = @header['status']
    @query_time = @header['QTime']
  end
  
  def ok?
    self.status==0
  end
  
end