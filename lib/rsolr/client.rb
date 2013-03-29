class RSolr::Client
  
  attr_reader :connection, :uri, :proxy, :options
  
  def initialize connection, options = {}
    @proxy = @uri = nil
    @connection = connection
    unless false === options[:url]
      url = options[:url] ? options[:url].dup : 'http://127.0.0.1:8983/solr/'
      url << "/" unless url[-1] == ?/
      @uri = RSolr::Uri.create url
      if options[:proxy]
        proxy_url = options[:proxy].dup
        proxy_url << "/" unless proxy_url.nil? or proxy_url[-1] == ?/
        @proxy = RSolr::Uri.create proxy_url if proxy_url
      end
    end
    @options = options
  end
  
  # returns the request uri object.
  def base_request_uri
    base_uri.request_uri if base_uri
  end
  
  # returns the uri proxy if present,
  # otherwise just the uri object.
  def base_uri
    @proxy ? @proxy : @uri
  end
  
  # Create the get, post, and head methods
  %W(get post head).each do |meth|
    class_eval <<-RUBY
    def #{meth} path, opts = {}, &block
      send_and_receive path, opts.merge(:method => :#{meth}), &block
    end
    RUBY
  end
  
  # A paginated request method.
  # Converts the page and per_page
  # arguments into "rows" and "start".
  def paginate page, per_page, path, opts = nil
    opts ||= {}
    opts[:params] ||= {}
    raise "'rows' or 'start' params should not be set when using +paginate+" if ["start", "rows"].include?(opts[:params].keys)
    execute build_paginated_request(page, per_page, path, opts)
  end
  
  # POST XML messages to /update with optional params.
  # 
  # http://wiki.apache.org/solr/UpdateXmlMessages#add.2BAC8-update
  #
  # If not set, opts[:headers] will be set to a hash with the key
  # 'Content-Type' set to 'text/xml'
  #
  # +opts+ can/should contain:
  #
  #  :data - posted data
  #  :headers - http headers
  #  :params - solr query parameter hash
  #
  def update opts = {}
    opts[:headers] ||= {}
    opts[:headers]['Content-Type'] ||= 'text/xml'
    post 'update', opts
  end
  
  # 
  # +add+ creates xml "add" documents and sends the xml data to the +update+ method
  # 
  # http://wiki.apache.org/solr/UpdateXmlMessages#add.2BAC8-update
  # 
  # single record:
  # solr.update(:id=>1, :name=>'one')
  #
  # update using an array
  # 
  # solr.update(
  #   [{:id=>1, :name=>'one'}, {:id=>2, :name=>'two'}],
  #   :add_attributes => {:boost=>5.0, :commitWithin=>10}
  # )
  # 
  def add doc, opts = {}
    add_attributes = opts.delete :add_attributes
    update opts.merge(:data => xml.add(doc, add_attributes))
  end

  # send "commit" xml with opts
  #
  # http://wiki.apache.org/solr/UpdateXmlMessages#A.22commit.22_and_.22optimize.22
  #
  def commit opts = {}
    commit_attrs = opts.delete :commit_attributes
    update opts.merge(:data => xml.commit( commit_attrs ))
  end

  # send "optimize" xml with opts.
  #
  # http://wiki.apache.org/solr/UpdateXmlMessages#A.22commit.22_and_.22optimize.22
  #
  def optimize opts = {}
    optimize_attributes = opts.delete :optimize_attributes
    update opts.merge(:data => xml.optimize(optimize_attributes))
  end
  
  # send </rollback>
  # 
  # http://wiki.apache.org/solr/UpdateXmlMessages#A.22rollback.22
  # 
  # NOTE: solr 1.4 only
  def rollback opts = {}
    update opts.merge(:data => xml.rollback)
  end
  
  # Delete one or many documents by id
  #   solr.delete_by_id 10
  #   solr.delete_by_id([12, 41, 199])
  def delete_by_id id, opts = {}
    update opts.merge(:data => xml.delete_by_id(id))
  end

  # delete one or many documents by query.
  # 
  # http://wiki.apache.org/solr/UpdateXmlMessages#A.22delete.22_by_ID_and_by_Query
  # 
  #   solr.delete_by_query 'available:0'
  #   solr.delete_by_query ['quantity:0', 'manu:"FQ"']
  def delete_by_query query, opts = {}
    update opts.merge(:data => xml.delete_by_query(query))
  end
  
  # shortcut to RSolr::Xml::Generator
  def xml
    @xml ||= RSolr::Xml::Generator.new
  end
  
  # +send_and_receive+ is the main request method responsible for sending requests to the +connection+ object.
  # 
  # "path" : A string value that usually represents a solr request handler
  # "opts" : A hash, which can contain the following keys:
  #   :method : required - the http method (:get, :post or :head)
  #   :params : optional - the query string params in hash form
  #   :data : optional - post data -- if a hash is given, it's sent as "application/x-www-form-urlencoded; charset=UTF-8"
  #   :headers : optional - hash of request headers
  # All other options are passed right along to the connection's +send_and_receive+ method (:get, :post, or :head)
  # 
  # +send_and_receive+ returns either a string or hash on a successful ruby request.
  # When the :params[:wt] => :ruby, the response will be a hash, else a string.
  #
  # creates a request context hash,
  # sends it to the connection's +execute+ method
  # which returns a simple hash,
  # then passes the request/response into +adapt_response+.
  def send_and_receive path, opts
    request_context = build_request path, opts
    [:open_timeout, :read_timeout, :retry_503, :retry_after_limit].each do |k|
      request_context[k] = @options[k]
    end
    execute request_context
  end
  
  # 
  def execute request_context

    raw_response = connection.execute self, request_context

    while retry_503?(request_context, raw_response)
      request_context[:retry_503] -= 1
      sleep retry_after(raw_response)
      raw_response = connection.execute self, request_context
    end

    adapt_response(request_context, raw_response) unless raw_response.nil?
  end

  def retry_503?(request_context, response)
    return false if response.nil?
    status = response[:status] && response[:status].to_i
    return false unless status == 503
    retry_503 = request_context[:retry_503]
    return false unless retry_503 && retry_503 > 0
    retry_after_limit = request_context[:retry_after_limit] || 1
    retry_after = retry_after(response)
    return false unless retry_after && retry_after <= retry_after_limit
    true
  end

  # Retry-After can be a relative number of seconds from now, or an RFC 1123 Date.
  # If the latter, attempt to convert it to a relative time in seconds.
  def retry_after(response)
    retry_after = Array(response[:headers]['Retry-After'] || response[:headers]['retry-after']).flatten.first
    if retry_after =~ /\A[0-9]+\Z/
      retry_after = retry_after.to_i
    else
      begin
        retry_after_date = DateTime.parse(retry_after)
        retry_after = retry_after_date.to_time - Time.now
        retry_after = nil if retry_after < 0
      rescue ArgumentError => e
        retry_after = retry_after.to_i
      end
    end
    retry_after
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
    opts[:proxy] = proxy unless proxy.nil?
    opts[:method] ||= :get
    raise "The :data option can only be used if :method => :post" if opts[:method] != :post and opts[:data]
    opts[:params] = opts[:params].nil? ? {:wt => :ruby} : {:wt => :ruby}.merge(opts[:params])
    query = RSolr::Uri.params_to_solr(opts[:params]) unless opts[:params].empty?
    opts[:query] = query
    if opts[:data].is_a? Hash
      opts[:data] = RSolr::Uri.params_to_solr opts[:data]
      opts[:headers] ||= {}
      opts[:headers]['Content-Type'] ||= 'application/x-www-form-urlencoded; charset=UTF-8'
    end
    opts[:path] = path
    opts[:uri] = base_uri.merge(path.to_s + (query ? "?#{query}" : "")) if base_uri
    opts
  end
  
  def build_paginated_request page, per_page, path, opts
    per_page = per_page.to_s.to_i
    page = page.to_s.to_i-1
    page = page < 1 ? 0 : page
    opts[:params]["start"] = page * per_page
    opts[:params]["rows"] = per_page
    build_request path, opts
  end
  
  #  A mixin for used by #adapt_response
  module Context
    attr_accessor :request, :response
  end
  
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
    raise RSolr::Error::Http.new request, response unless [200,302].include? response[:status]
    result = request[:params][:wt] == :ruby ? evaluate_ruby_response(request, response) : response[:body]
    result.extend Context
    result.request, result.response = request, response
    result.is_a?(Hash) ? result.extend(RSolr::Response) : result
  end
  
  protected
  
  # converts the method name for the solr request handler path.
  def method_missing name, *args
    if name.to_s =~ /^paginated?_(.+)$/
      paginate args[0], args[1], $1, *args[2..-1]
    else
      send_and_receive name, *args
    end
  end
  
  # evaluates the response[:body],
  # attempts to bring the ruby string to life.
  # If a SyntaxError is raised, then
  # this method intercepts and raises a
  # RSolr::Error::InvalidRubyResponse
  # instead, giving full access to the
  # request/response objects.
  def evaluate_ruby_response request, response
    begin
      Kernel.eval response[:body].to_s
    rescue SyntaxError
      raise RSolr::Error::InvalidRubyResponse.new request, response
    end
  end
  
end
