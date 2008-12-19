require 'rubygems'
require 'curb'

class Solr::HTTP::Adapter::Curb
  
  include Solr::HTTP::Util
  
  attr :uri
  attr :c
  
  def initialize(url)
    @uri = URI.parse(url)
    @c = ::Curl::Easy.new
  end
  
  def get(path, params={})
    @c.url = _build_url(path, params)
    @c.multipart_form_post = false
    @c.perform
    raise Solr::RequestError unless @c.response_code.to_s=='200'
    @c.body_str
  end
  
  def post(path, data, params={}, headers={})
    @c.url = _build_url(path, params)
    @c.headers = headers
    @c.http_post(data)
    raise Solr::RequestError unless @c.response_code.to_s=='200'
    @c.body_str
  end
  
  protected
  
  def _build_url(path, params={})
    url = @uri.scheme + '://' + @uri.host
    url += ':' + @uri.port.to_s if @uri.port
    url += @uri.path + path
    build_url(url, params, @uri.query)
  end
  
end