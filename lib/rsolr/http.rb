require 'net/http'
require 'net/https'

class RSolr::Http
  
  include RSolr::Requestable
  include RSolr::Responseable
  
  # No need for a constructor here, we have RSolr::Requestable for that.
  
  # using the request_context hash,
  # send a request,
  # then return the standard rsolr response hash {:status, :body, :headers}
  def execute request_context
    request = setup_raw_request request_context
    request.body = request_context[:data] if request_context[:method] == :post and request_context[:data]
    begin
      response = http.request request
      {:status => response.code.to_i, :headers => response.to_hash, :body => response.body}
    rescue NoMethodError
      $!.message == "undefined method `closed?' for nil:NilClass" ?
        raise(Errno::ECONNREFUSED.new) :
        raise($!)
    end
  end
  
  # This returns a singleton of a Net::HTTP or Net::HTTP.Proxy request object.
  def http
    @http ||= (
      http = if proxy
        proxy_user, proxy_pass = proxy.userinfo.split(/:/) if proxy.userinfo
        Net::HTTP.Proxy(proxy.host, proxy.port, proxy_user, proxy_pass).new uri.host, uri.port
      else
        Net::HTTP.new uri.host, uri.port
      end
      http.use_ssl = uri.port == 443 || uri.instance_of?(URI::HTTPS)      
      http
    )
  end
  
  # 
  def setup_raw_request request_context
    http_method = case request_context[:method]
    when :get
      Net::HTTP::Get
    when :post
      Net::HTTP::Post
    when :head
      Net::HTTP::Head
    else
      raise "Only :get, :post and :head http method types are allowed."
    end
    headers = request_context[:headers] || {}
    raw_request = http_method.new request_context[:uri].to_s
    raw_request.initialize_http_header headers
    raw_request
  end
  
end