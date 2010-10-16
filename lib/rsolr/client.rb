class RSolr::Client
  
  attr_reader :connection, :uri, :proxy, :options
  
  def initialize connection, options = {}
    @connection = connection
    url = options[:url] || 'http://127.0.0.1:8983/solr/'
    url << "/" unless url[-1] == ?/
    proxy_url = options[:proxy]
    proxy_url << "/" unless proxy_url.nil? or proxy_url[-1] == ?/
    @uri = RSolr::Uri.create url
    @proxy = RSolr::Uri.create proxy_url if proxy_url
    @options = options
    extend RSolr::Pagination::Client
  end
  
  # 
  def base_request_uri
    base_uri.request_uri
  end
  
  #
  def base_uri
    @proxy || @uri
  end
  
  # Create the get, post, and head methods
  %W(get post head).each do |meth|
    class_eval <<-RUBY
    def #{meth} path, opts = {}, &block
      send_and_receive path, opts.merge(:method => :#{meth}), &block
    end
    RUBY
  end
  
  # converts the method name for the solr request handler path.
  def method_missing name, *args
    send_and_receive name, *args
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
  
  # shortcut to RSolr::Message::Generator
  def xml
    @xml ||= RSolr::Xml::Generator.new
  end
  
  # +send_and_receive+ is the main request method responsible for sending requests to the +connection+ object.
  # 
  # "path" : A string value that usually represents a solr request handler
  # "opt" : A hash, which can contain the following keys:
  #   :method : required - the http method (:get, :post or :head)
  #   :params : optional - the query string params in hash form
  #   :data : optional - post data -- if a hash is given, it's sent as "application/x-www-form-urlencoded"
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
    execute request_context
  end
  
  # 
  def execute request_context
    raw_response = connection.execute self, request_context
    adapt_response(request_context, raw_response) unless raw_response.nil?
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
      opts[:headers]['Content-Type'] ||= 'application/x-www-form-urlencoded'
    end
    opts[:path] = path
    opts[:uri] = base_uri.merge(path.to_s + (query ? "?#{query}" : "")) if base_uri
    opts
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
    raise RSolr::Error::Http.new request, response unless
      [200,302].include? response[:status]
    data = response[:body]
    if request[:params][:wt] == :ruby
      begin
        data = evaluate_ruby_response data.to_s
      rescue SyntaxError
        raise RSolr::Error::InvalidRubyResponse.new request, response
      end
    end
    data
  end
  
  def evaluate_ruby_response ruby_string
    Kernel.eval ruby_string
  end
  
end