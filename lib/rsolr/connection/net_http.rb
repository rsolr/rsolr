require 'net/http'

#
# Connection for standard HTTP Solr server
#
class RSolr::Connection::NetHttp
  
  include RSolr::Connection::Requestable
  
  def connection
    if @proxy
      proxy_user, proxy_pass = @proxy.userinfo.split(/:/) if @proxy.userinfo
      @connection ||= Net::HTTP.Proxy(@proxy.host, @proxy.port, proxy_user, proxy_pass).new(@uri.host, @uri.port)
    else
      @connection ||= Net::HTTP.new(@uri.host, @uri.port)
    end
  end
  
  def get url
    net_http_response = self.connection.get url
    [net_http_response.body, net_http_response.code.to_i, net_http_response.message]
  end
  
  def post url, data, headers={}
    net_http_response = self.connection.post url, data, headers
    [net_http_response.body, net_http_response.code.to_i, net_http_response.message]
  end
  
end