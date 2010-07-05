class RSolr::Client
  
  attr_reader :connection
  
  def initialize connection
    @connection = connection
  end
  
  %W(get post head).each do |meth|
    class_eval <<-RUBY
    def #{meth} path, opts = {}, &block
      send_request path, opts.merge(:method => :#{meth}), &block
    end
    RUBY
  end
  
  def method_missing name, *args, &block
    path = name.to_s
    send_request path, *args, &block
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
  def update opts = {}, &block
    opts[:headers] ||= {}
    opts[:headers]['Content-Type'] ||= 'text/xml'
    post 'update', opts, &block
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
    add_attributes = opts.delete :add_attributes
    update opts.merge(:data => xml.add(doc, add_attributes), &block)
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
    commit_attrs = opts.delete :commit_attributes
    update opts.merge(:data => xml.commit( commit_attrs, &block ))
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
  def optimize opts = {}, &block
    optimize_attributes = opts.delete :optimize_attributes
    update opts.merge(:data => xml.optimize(opts[:optimize_attributes])), &block
  end
  
  # send </rollback>
  # NOTE: solr 1.4 only
  def rollback opts = {}, &block
    update opts.merge(:data => xml.rollback), &block
  end

  # Delete one or many documents by id
  #   solr.delete_by_id 10
  #   solr.delete_by_id([12, 41, 199])
  def delete_by_id id, opts = {}, &block
    update opts.merge(:data => xml.delete_by_id(id)), &block
  end

  # delete one or many documents by query
  #   solr.delete_by_query 'available:0'
  #   solr.delete_by_query ['quantity:0', 'manu:"FQ"']
  def delete_by_query query, opts = {}, &block
    update opts.merge(:data => xml.delete_by_query(query)), &block
  end
  
  # shortcut to RSolr::Message::Generator
  def xml
    @xml ||= RSolr::Xml::Generator.new
  end
  
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
  # If the connection request method returns nil, +send_request+ returns immediately.
  # This feature is mainly for event based connection drivers.  
  # 
  def send_request path, opts = {}, &block
    opts[:method] ||= :get
    raise "The :data option can only be used if :method => :post" if
      opts[:method] != :post and opts[:data]
    request_context = build_request path, opts
    if opts[:noop]
      if block_given?
        yield request_context, nil
        return
      end
    end
    response = nil
    begin
      response = connection.send opts[:method], request_context
      # if this connection driver doesn't return a hash, don't send it thru adapt_response
      # instead, yield the request_context along with the response object.
      unless response.is_a? Hash
        yield request_context, response
        return
      end
      res = adapt_response request_context, response
      # here, adapt_response was successful, so yield
      yield request_context, response if block_given?
      # and return the final result
      return res
    rescue
      # either the connection.send failed or the adapt_response failed...
      yield request_context, response if block_given?
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
    if data.is_a? Hash
      data = RSolr::Uri.params_to_solr data
      headers['Content-Type'] ||= 'application/x-www-form-urlencoded'
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
    raise "The response does not have the correct keys => :body, :headers, :status" unless
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
    data
  end
  
end