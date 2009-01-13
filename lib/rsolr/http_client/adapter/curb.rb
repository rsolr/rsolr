require 'rubygems'
require 'curb'

class RSolr::HTTPClient::Adapter::Curb
  
  include RSolr::HTTPClient::Util
  
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
    create_http_context(path, params)
  end
  
  def post(path, data, params={}, headers={})
    @c.url = _build_url(path, params)
    @c.headers = headers
    @c.http_post(data)
    create_http_context(path, params, data, headers)
  end
  
  protected
  
  def create_http_context(path, params, data=nil, headers={})
    {
      :status_code=>@c.response_code.to_i,
      :url=>@c.url,
      :body=>@c.body_str,
      :path=>path,
      :params=>params,
      :data=>data,
      :headers=>headers
    }
  end
  
  def _build_url(path, params={})
    url = @uri.scheme + '://' + @uri.host
    url += ':' + @uri.port.to_s if @uri.port
    url += @uri.path + path
    build_url(url, params, @uri.query)
  end
  
end