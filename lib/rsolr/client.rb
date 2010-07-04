class RSolr::Client
  
  attr_reader :connection
  
  def initialize connection
    @connection = connection
  end
  
  %W(get post head).each do |meth|
    class_eval <<-RUBY
    def #{meth} path, opts = {}
      send_request path, opts.merge(:method => :#{meth})
    end
    RUBY
  end
  
  # method_missing -- method name is converted to the "path" value.
  # The http :method option is :get by default.
  def method_missing name, opts = {}
    opts[:method] ||= :get
    send_request name.to_s, opts
  end
  
  module DocSetPagination
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
  
  # solr.paginate "select", 1, 10, :params => {:q=>"*:*"}
  def paginate page, per_page, path, opts = {}
    page = page.to_s.to_i
    per_page = per_page.to_s.to_i
    opts[:method] ||= :get
    opts[:params] ||= {}
    opts[:params][:rows] = per_page
    page = page - 1
    page = page < 1 ? 0 : page
    opts[:params][:start] = page * opts[:params][:rows]
    result = send_request path, opts
    docs = result["response"]["docs"]
    docs.extend DocSetPagination
    docs.per_page = per_page
    docs.start = opts[:params][:start]
    docs.total = result["response"]["numFound"].to_s.to_i
    result
  end
  
  # POST XML messages to /update with optional params
  #
  # If not set, opts[:headers] will be set to a hash with the key
  # 'Content-Type' set to 'text/xml'
  #
  # +opts+ can/should contain:
  #
  #  :data - posted data
  #  :headers - http headers
  #  :params - query parameter hash
  #
  def update opts = {}
    opts[:headers] ||= {}
    opts[:headers]['Content-Type'] ||= 'text/xml'
    post 'update', opts
  end
  
  # 
  # +add+ creates xml "add" documents and sends the xml data to the +update+ method
  # single record:
  # solr.update(:id=>1, :name=>'one')
  #
  # update using an array
  # 
  # solr.update(
  #   [{:id=>1, :name=>'one'}, {:id=>2, :name=>'two'}],
  #   :add_attrs => {:boost=>5.0, :commitWithin=>10}
  # )
  # 
  def add doc, opts = {}, &block
    add_attrs = opts.delete :add_attrs
    update opts.merge(:data => xml.add(doc, add_attrs, &block))
  end

  # send "commit" xml with opts
  #
  # opts recognized by solr
  #
  #   :maxSegments    => N - optimizes down to at most N number of segments
  #   :waitFlush      => true|false - do not return until changes are flushed to disk
  #   :waitSearcher   => true|false - do not return until a new searcher is opened and registered
  #   :expungeDeletes => true|false - merge segments with deletes into other segments #NOT
  #
  # *NOTE* :expungeDeletes is Solr 1.4 only
  #
  def commit opts = {}, &block
    commit_attrs = opts.delete :commit_attrs
    update opts.merge(:data => xml.commit( opts[:commit_attrs], &block ))
  end

  # send "optimize" xml with opts.
  #
  # opts recognized by solr
  #
  #   :maxSegments    => N - optimizes down to at most N number of segments
  #   :waitFlush      => true|false - do not return until changes are flushed to disk
  #   :waitSearcher   => true|false - do not return until a new searcher is opened and registered
  #   :expungeDeletes => true|false - merge segments with deletes into other segments
  #
  # *NOTE* :expungeDeletes is Solr 1.4 only
  #
  def optimize opts = {}
    optimize_attrs = opts.delete :optimize_attrs
    update opts.merge(:data => xml.optimize(opts[:optimize_attrs]))
  end
  
  # send </rollback>
  # NOTE: solr 1.4 only
  def rollback
    update :data => xml.rollback
  end

  # Delete one or many documents by id
  #   solr.delete_by_id 10
  #   solr.delete_by_id([12, 41, 199])
  def delete_by_id id
    update :data => xml.delete_by_id(id)
  end

  # delete one or many documents by query
  #   solr.delete_by_query 'available:0'
  #   solr.delete_by_query ['quantity:0', 'manu:"FQ"']
  def delete_by_query query
    update :data => xml.delete_by_query(query)
  end
  
  # shortcut to RSolr::Message::Generator
  def xml
    @xml ||= RSolr::Xml::Generator.new
  end
  
  # raised if the request/response is not valid.
  class ValidationError < RuntimeError; end
  
  # +send_request+ is the main request method.
  # 
  # "path" : A string value that usually represents a solr request handler
  # "opt" : A hash, which can contain the following keys:
  #   :method : required - the http method (:get, :post or :head)
  #   :params : optional - the query string params in hash form
  #   :data : optional - post data -- if a hash is given, it's sent as "application/x-www-form-urlencoded"
  #   :headers : optional - hash of request headers
  # All other options are passed right along to the connection request method (:get, :post, or :head)
  #
  # +send_request+ returns either a string or hash on a successful request.
  # When the :params[:wt] => :ruby, the response will be a hash, else a string.
  # In both cases, the +adapt_response+ method adds a :response and :request method to the return object,
  # which contains the original request and response info.
  # 
  # +send_request+ raises an error if the response from the connection is NOT a hash,
  # or the connection returned a hash that does not have the keys, :status, :body and :headers.
  # NOTE: If the connection request method returns nil, nothing is returned.
  # 
  # +send_request+ raises an RSolr::Error::Http if the :status != 200 or 302
  # 
  # In all cases, the exception instance will have a :request method attached,
  # and if a response was returned, a :response method attached. These methods
  # contain the original request/response information.
  # 
  def send_request path, opts = {}
    raise ValidationError.new "Validation Error: The :method option is required" if
      opts[:method].nil?
    raise ValidationError.new "Validation Error: The :data option can only be used if :method => :post" if
      opts[:method] != :post and opts[:data]
    request_context = build_request path, opts
    return request_context if opts[:noop]
    begin
      response = connection.send opts[:method], request_context
      return response if response.nil?
      return adapt_response request_context, response
    rescue
      unless $!.respond_to? :request
        $!.extend(RSolr::Error::SolrContext).request = request_context
      end
      raise $!
    end
  end
  
  # merges {:wt => :ruby} if :wt does not exist.
  def map_params params
    params = params.nil? ? {} : params.dup
    params[:wt] ||= :ruby
    params
  end
  
  # build_request sets up the uri/query string
  # and converts the +data+ arg to form-urlencoded
  # if the +data+ arg is a hash.
  def build_request path, opts
    opts[:params] = map_params opts[:params]
    params, data, headers = opts[:params], opts[:data], opts[:headers]
    headers ||= {}
    query = RSolr::Uri.params_to_solr(params)
    if data
      if data.is_a? Hash
        data = RSolr::Uri.params_to_solr data
        headers['Content-Type'] ||= 'application/x-www-form-urlencoded'
      end
    end
    opts.merge({
      :path => path.to_s,
      :data => data,
      :headers => headers,
      :query => query,
      :client => self
    })
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
    raise ValidationError.new "The response does not have the correct keys => :body, :headers, :status" unless
      %W(body headers status) == response.keys.map{|k|k.to_s}.sort
    raise RSolr::Error::Http.new request, response unless
      [200,302].include? response[:status]
    data = response[:body]
    if request[:params][:wt] == :ruby
      begin
        data = Kernel.eval data.to_s
      rescue SyntaxError
        raise RSolr::Error::InvalidRubyResponse.new request, response
      end
    end
    data.extend Module.new.instance_eval{attr_accessor :request, :response; self}
    data.request = request
    data.response = response
    data
  end
  
end