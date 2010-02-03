require 'net/http'

#
# Connection for standard HTTP Solr server
#
class RSolr::Connection::NetHttp
  
  include RSolr::Connection::Requestable
  
  protected
  
  def connection
    @connection ||= Net::HTTP.new(@uri.host, @uri.port)
  end
  
  def get path, params={}
    url = self.build_url path, params
    net_http_response = self.connection.get url
    create_http_context net_http_response, url, path, params
  end
  
  def post path, data, params={}, headers={}
    url = self.build_url path, params
    net_http_response = self.connection.post url, data, headers
    create_http_context net_http_response, url, path, params, data, headers
  end
  
  def create_http_context net_http_response, url, path, params, data=nil, headers={}
    full_url = "#{@uri.scheme}://#{@uri.host}"
    full_url += @uri.port ? ":#{@uri.port}" : ''
    full_url += url
    {
      :status_code=>net_http_response.code.to_i,
      :url=>full_url,
      :body=> encode_utf8(net_http_response.body),
      :path=>path,
      :params=>params,
      :data=>data,
      :headers=>headers,
      :message => net_http_response.message
    }
  end
  
  # accepts a path/string and optional hash of query params
  def build_url path, params={}
    full_path = @uri.path + path
    super full_path, params, @uri.query
  end
  
end