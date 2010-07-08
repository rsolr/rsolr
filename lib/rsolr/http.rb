require 'net/http'
require 'net/https'

class RSolr::Http
  
  include RSolr::Connectable
  
  def initialize *args, &block
    # call the initialize method from RSolr::Connectable
    super
  end
  
  # using the request_context hash,
  # issue a request,
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
  
  protected
  
  def http
    @http ||= (
      http = if proxy
        proxy_user, proxy_pass = proxy.userinfo.split(/:/) if proxy.userinfo
        Net::HTTP.Proxy(proxy.host, proxy.port, proxy_user, proxy_pass).new uri.host, uri.port
      else
        Net::HTTP.new uri.host, uri.port
      end
    
      http.use_ssl = uri.port == 443 || uri.instance_of?(URI::HTTPS)

      if options[:timeout] && options[:timeout].is_a?(Integer)
        http.open_timeout = options[:timeout]
        http.read_timeout = options[:timeout]
      end

      if options[:pem] && http.use_ssl?
        http.cert = OpenSSL::X509::Certificate.new(options[:pem])
        http.key = OpenSSL::PKey::RSA.new(options[:pem])
        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      else
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      end

      if options[:debug_output]
        http.set_debug_output(options[:debug_output])
      end

      http
    )
  end
  
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
    raw_request.basic_auth username, password if options[:basic_auth]
    if options[:digest_auth]
      res = http.head(request_context[:uri].to_s, headers)
      if res['www-authenticate'] != nil && res['www-authenticate'].length > 0
        raw_request.digest_auth username, password, res
      end
    end
    raw_request
  end
  
  def credentials
    options[:basic_auth] || options[:digest_auth]
  end

  def username
    credentials[:username]
  end

  def password
    credentials[:password]
  end
  
end