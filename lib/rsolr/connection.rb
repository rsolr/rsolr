require 'net/http'
require 'net/https'

# The default/Net::Http adapter for RSolr.
class RSolr::Connection

  # using the request_context hash,
  # send a request,
  # then return the standard rsolr response hash {:status, :body, :headers}
  def execute client, request_context
    h = http request_context[:uri], request_context[:proxy], request_context[:read_timeout], request_context[:open_timeout]
    request = setup_raw_request request_context
    request.body = request_context[:data] if request_context[:method] == :post and request_context[:data]
    begin
      response = h.request request
      charset = response.type_params["charset"]
      {:status => response.code.to_i, :headers => response.to_hash, :body => force_charset(response.body, charset)}
    rescue Errno::ECONNREFUSED => e
      raise(Errno::ECONNREFUSED.new(request_context.inspect))
    # catch the undefined closed? exception -- this is a confirmed ruby bug
    rescue NoMethodError
      $!.message == "undefined method `closed?' for nil:NilClass" ?
        raise(Errno::ECONNREFUSED.new) :
        raise($!)
    end
  end

  protected

  # This returns a singleton of a Net::HTTP or Net::HTTP.Proxy request object.
  def http uri, proxy = nil, read_timeout = nil, open_timeout = nil
    @http ||= (
      http = if proxy
        proxy_user, proxy_pass = proxy.userinfo.split(/:/) if proxy.userinfo
        Net::HTTP.Proxy(proxy.host, proxy.port, proxy_user, proxy_pass).new uri.host, uri.port
      else
        Net::HTTP.new uri.host, uri.port
      end
      http.use_ssl = uri.port == 443 || uri.instance_of?(URI::HTTPS)
      http.read_timeout = read_timeout if read_timeout
      http.open_timeout = open_timeout if open_timeout
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
    raw_request = http_method.new request_context[:uri].request_uri
    raw_request.initialize_http_header headers
    raw_request.basic_auth(request_context[:uri].user, request_context[:uri].password) if request_context[:uri].user && request_context[:uri].password
    raw_request
  end

  private

  def force_charset body, charset
    return body unless charset and body.respond_to?(:force_encoding)
    body.force_encoding(charset)
  end

end