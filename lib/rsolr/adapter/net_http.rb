require 'net/http'

#
# Connection for standard HTTP Solr server
class RSolr::Adapter::NetHttp
  
  include RSolr::Connectable
  
  def connection
    @connection ||= (
      if @proxy
        proxy_user, proxy_pass = @proxy.userinfo.split(/:/) if @proxy.userinfo
        Net::HTTP.Proxy(@proxy.host, @proxy.port, proxy_user, proxy_pass).new(@uri.host, @uri.port)
      else
        Net::HTTP.new(@uri.host, @uri.port)
      end
    )
  end
  
  # returns [status, headers, body]
  def get uri
    execute :get, uri
  end
  
  # returns [status, headers, body]
  def post uri, data, headers={}
    execute :post, uri, data, headers
  end
  
  protected
  
  # making up for http://redmine.ruby-lang.org/issues/show/2708
  def execute method, uri, data = nil, headers = {}
    begin
      net_http_response = method == :post ? self.connection.request_post(uri.to_s, data, headers) : self.connection.request_get(uri.to_s)
    rescue NoMethodError
      $!.message == "undefined method `closed?' for nil:NilClass" ?
        raise(Errno::ECONNREFUSED.new) :
        raise($!)
    end
    [net_http_response.code.to_i, net_http_response.to_hash, net_http_response.body]
  end
  
end