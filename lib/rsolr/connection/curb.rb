require 'curb'

#
# Connection for standard HTTP Solr server
#
class RSolr::Connection::Curb
  
  include RSolr::Connection::Utils
  include RSolr::Connection::Httpable
  
  protected
  
  def connection
    @connection ||= ::Curl::Easy.new
  end
  
  def get path, params={}
    connection.url = build_url path, params
    connection.multipart_form_post = false
    connection.perform
    create_http_context path, params
  end
  
  def post path, data, params={}, headers={}
    connection.url = build_url path, params
    connection.headers = headers
    connection.http_post data
    create_http_context path, params, data, headers
  end
  
  def create_http_context path, params, data=nil, headers={}
    {
      :status_code => connection.response_code.to_i,
      :url => connection.url,
      :body => connection.body_str,
      :path => path,
      :params => params,
      :headers => headers,
      :data => data,
      :message => ''
    }
  end
  
  # accepts a path/string and optional hash of query params
  def build_url path, params={}
    url = @uri.scheme + '://' + @uri.host
    url += ':' + @uri.port.to_s if @uri.port
    url += @uri.path + path
    super url, params, @uri.query # build_url is coming from RSolr::Connection::Utils
  end
  
end