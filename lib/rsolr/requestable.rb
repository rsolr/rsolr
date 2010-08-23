# Requestable is designed to be shared across solr driver implementations.
# If the driver uses an http url/proxy and returns the standard http response
# data (status, body, headers) then this module can be used.
#
# Requestable also handles :page/:per_page => :start/:rows
# logic for the request.
module RSolr::Requestable
  
  attr_reader :uri, :proxy, :options
  
  def initialize options = {}
    url = options[:url] || 'http://127.0.0.1:8983/solr/'
    url << "/" unless url[-1] == ?/
    proxy_url = options[:proxy]
    proxy_url << "/" unless proxy_url.nil? or proxy_url[-1] == ?/
    @uri = RSolr::Uri.create url
    @proxy = RSolr::Uri.create proxy_url if proxy_url
    @options = options
  end
  
  # 
  def base_request_uri
    base_uri.request_uri
  end
  
  def base_uri
    @proxy || @uri
  end
  
  # creates a request context hash,
  # sends it to the connection.execute method
  # which returns a simple hash,
  # then passes the request/response into adapt_response.
  def send_request path, opts
    request_context = build_request path, opts
    raw_response = execute request_context
    adapt_response request_context, raw_response
  end
  
  # all connection imlementations that use this mixin need to create an execute method 
  def execute request_context
    raise "You gotta implement this method and return a hash like => {:status => <integer>, :body => <string>, :headers => <hash>}"
  end
  
  # +build_request+ accepts a path and options hash,
  # then prepares a normalized hash to return for sending
  # to a solr connection driver.
  # +build_request+ sets up the uri/query string
  # and converts the +data+ arg to form-urlencoded,
  # if the +data+ arg is a hash.
  # returns a hash with the following keys:
  #   :method
  #   :params
  #   :headers
  #   :data
  #   :uri
  #   :path
  #   :query
  def build_request path, opts
    raise "path must be a string or symbol, not #{path.inspect}" unless [String,Symbol].include?(path.class)
    path = path.to_s
    opts[:method] ||= :get
    raise "The :data option can only be used if :method => :post" if opts[:method] != :post and opts[:data]
    calculate_start_and_rows opts
    opts[:params] = opts[:params].nil? ? {:wt => :ruby} : {:wt => :ruby}.merge(opts[:params])
    query = RSolr::Uri.params_to_solr(opts[:params]) unless opts[:params].empty?
    opts[:query] = query
    if opts[:data].is_a? Hash
      opts[:data] = RSolr::Uri.params_to_solr opts[:data]
      opts[:headers] ||= {}
      opts[:headers]['Content-Type'] ||= 'application/x-www-form-urlencoded'
    end
    opts[:path] = path
    opts[:uri] = base_uri.merge(path.to_s + (query ? "?#{query}" : "")) if base_uri
    opts
  end
  
  # figures out the "start" and "rows" Solr params
  # by inspecting the :per_page and :page params.
  def calculate_start_and_rows request
    return unless request[:page] and request[:per_page]
    page, per_page = request[:page], request[:per_page]
    per_page ||= 10
    page = page.to_s.to_i-1
    page = page < 1 ? 0 : page
    start = page * per_page
    request[:params].merge! :start => start, :rows => per_page
  end
  
end