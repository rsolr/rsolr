# default/base response object
class Solr::Response::Base
  
  attr_reader :raw_response, :data, :header, :params, :status, :query_time
  
  def initialize(data)
    if data.is_a?(String)
      @raw_response = data
      @data = Kernel.eval(@raw_response)
    else
      @data = data
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