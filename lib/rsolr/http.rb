module RSolr
  
  class Http
    
    attr_reader :uri, :proxy, :options
    
    def initialize base_url, options = {}
      @options = options
      @uri = base_url
      @proxy = options[:proxy]
    end
    
    def base_uri
      @proxy ? @proxy.request_uri : @uri.request_uri
    end
    
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
  
    # send in path w/query
    def get options
      request_uri = options[:uri]
      headers = options[:headers] || {}
      req = setup_raw_request Net::HTTP::Get, request_uri, headers
      perform_request http, req, options
    end
  
    # send in path w/query
    def head options
      request_uri = options[:uri]
      headers = options[:headers] || {}
      req = setup_raw_request Net::HTTP::Head, request_uri, headers
      perform_request http, req, options
    end
  
    # send in path w/query
    def post options
      request_uri = options[:uri]
      data = options[:data]
      headers = options[:headers] || {}
      req = setup_raw_request Net::HTTP::Post, request_uri, headers
      req.body = data if data
      perform_request http, req, options
    end
    
    def perform_request http, request, options
      begin
        response = http.request request
        {:status => response.code.to_i, :headers => response.to_hash, :body => response.body}
      rescue NoMethodError
        $!.message == "undefined method `closed?' for nil:NilClass" ?
          raise(Errno::ECONNREFUSED.new) :
          raise($!)
      end
    end
    
    def setup_raw_request http_method, request_uri, headers = {}
      raw_request = http_method.new "#{base_uri}#{request_uri}"
      raw_request.initialize_http_header headers
      raw_request.basic_auth username, password if options[:basic_auth]
      if options[:digest_auth]
        res = http.head(request_uri, headers)
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
  
end