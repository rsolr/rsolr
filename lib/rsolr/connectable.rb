# Connectable is designed to be shared across solr driver implementations.
# If the driver uses an http url/proxy and returns the standard http response
# data (status, body, headers) then this module can be used. 
module RSolr::Connectable
  
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
  
  # build_request sets up the uri/query string
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
  
  #
  # TODO: The code below, related to responses,
  # should be moved to a response module/class!
  #
  
  # This method will evaluate the :body value
  # if the params[:uri].params[:wt] == :ruby
  # ... otherwise, the body is returned as is.
  # The return object has methods attached, :request and :response.
  # These methods give you access to the original
  # request and response from the connection.
  #
  # +adapt_response+ will raise an InvalidRubyResponse
  # if :wt == :ruby and the body
  # couldn't be evaluated.
  def adapt_response request, response
    raise "The response does not have the correct keys => :body, :headers, :status" unless
      %W(body headers status) == response.keys.map{|k|k.to_s}.sort
    raise RSolr::Error::Http.new request, response unless
      [200,302].include? response[:status]
    data = response[:body]
    if request[:params][:wt] == :ruby
      begin
        data = Kernel.eval data.to_s
        decorate_ruby_response request, data
      rescue SyntaxError
        raise RSolr::Error::InvalidRubyResponse.new request, response
      end
    end
    data
  end
  
  # TODO: Might want to move the logic from 
  # PaginatedResponse.extended to this method,
  # since we have access to the original 
  # reuqest and wouldn't require that
  # omitHeader != false.
  def decorate_ruby_response request, data
    if request[:page] and request[:per_page] and data["response"]["docs"]
      data.extend PaginatedResponse
    end
  end
  
  # figures out the "start" and "rows" Solr params
  # by inspecting the :per_page and :page params.
  def calculate_start_and_rows request
    page, per_page = request[:page], request[:per_page]
    per_page ||= 10
    page = page.to_s.to_i-1
    page = page < 1 ? 0 : page
    start = page * per_page
    request[:params].merge! :start => start, :rows => per_page
  end
  
  module PaginatedDocSet

    attr_accessor :start, :per_page, :total

    # Returns the current page calculated from 'rows' and 'start'
    # WillPaginate hook
    def current_page
      return 1 if start < 1
      per_page_normalized = per_page < 1 ? 1 : per_page
      @current_page ||= (start / per_page_normalized).ceil + 1
    end

    # Calcuates the total pages from 'numFound' and 'rows'
    # WillPaginate hook
    def total_pages
      @total_pages ||= per_page > 0 ? (total / per_page.to_f).ceil : 1
    end

    # returns the previous page number or 1
    # WillPaginate hook
    def previous_page
      @previous_page ||= (current_page > 1) ? current_page - 1 : 1
    end

    # returns the next page number or the last
    # WillPaginate hook
    def next_page
      @next_page ||= (current_page == total_pages) ? total_pages : current_page+1
    end

    def has_next?
      current_page < total_pages
    end

    def has_previous?
      current_page > 1
    end

  end
  
  module PaginatedResponse
    
    # TODO: self["responseHeader"]["params"]["rows"]
    # will not be available if omitHeader is false...
    # so, a simple "extend" probably isn't going to cut it.
    def self.extended base
      d = base['response']['docs']
      d.extend PaginatedDocSet
      d.per_page = self["responseHeader"]["params"]["rows"].to_s.to_i rescue 10
      d.start = base["response"]["start"].to_s.to_i
      d.total = base["response"]["numFound"].to_s.to_i
    end
  
  end
  
end