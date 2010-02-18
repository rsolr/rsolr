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
  
  def get context
    begin
      net_http_response = self.connection.get context[:url]
    rescue
      raise "#{$!} -> #{context.inspect}"
    end
    {:body => net_http_response.body, :status_code => net_http_response.code.to_i, :message => net_http_response.message}
  end
  
  def post context
    #url = self.build_url path, params
    #context = create_request_context url, path, params, data, headers
    begin
      net_http_response = self.connection.post context[:url], context[:data], context[:headers]
    rescue
      raise "#{$!} -> #{context.inspect}"
    end
    {:body => net_http_response.body, :status_code => net_http_response.code.to_i, :message => net_http_response.message}
  end
  
end