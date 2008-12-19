require 'net/http'

class Solr::HTTP::Adapter::NetHTTP
  
  include Solr::HTTP::Util
  
  attr :uri
  attr :c
  
  def initialize(url)
    @uri = URI.parse(url)
    @c = Net::HTTP.new(@uri.host, @uri.port)
  end
  
  def get(path, params={})
    response = @c.get(_build_url(path, params))
    raise Solr::RequestError.new(response.body) unless response.code.to_s=='200'
    response.body
  end
  
  def post(path, data, params={}, headers={})
    response = @c.post(_build_url(path, params), data, headers)
    raise Solr::RequestError.new(response.body) unless response.code.to_s=='200'
    response.body
  end
  
  protected
  
  def _build_url(path, params={})
    build_url(@uri.path + path, params, @uri.query)
  end
  
end