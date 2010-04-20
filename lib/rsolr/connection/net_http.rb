require 'net/http'

#
# Connection for standard HTTP Solr server
#
class RSolr::Connection::NetHttp
  
  include RSolr::Connection::Httpable
  
  def connection
    if @proxy
      proxy_user, proxy_pass = @proxy.userinfo.split(/:/) if @proxy.userinfo
      @connection ||= Net::HTTP.Proxy(@proxy.host, @proxy.port, proxy_user, proxy_pass).new(@uri.host, @uri.port)
    else
      @connection ||= Net::HTTP.new(@uri.host, @uri.port)
    end
  end
  
  # maybe follow Rack and do [status, headers, body]
  def get uri
    net_http_response = self.connection.get uri.to_s
    [net_http_response.code.to_i, net_http_response.message, net_http_response.body]
  end
  
  def post uri, data, headers={}
    net_http_response = self.connection.post uri.to_s, data, headers
    [net_http_response.code.to_i, net_http_response.message, net_http_response.body]
  end
  
end