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
  
  # method_missing -- method name is converted to the "path"
  # value and the http :method opt is :get by default.
  def method_missing name, opts = {}
    opts[:method] ||= :get
    send_request name.to_s, opts
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
  # +send_request+ returns either a string or hash with a successful request.
  # When the :params[:wt] => :ruby, the response will be a hash, other wise a string.
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
    raise ValidationError.new("Validation Error: The :method option is required") if opts[:method].nil?
    raise ValidationError.new("Validation Error: The :data option can only be used if :method => :post") if opts[:method] != :post and opts[:data]
    request_context = build_request path, opts
    begin
      response = connection.send opts[:method], request_context
      return response unless response.is_a? Hash
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
    query_string = RSolr::Uri.params_to_solr params if params
    request_uri = query_string.nil? ? path : "#{path}?#{query_string}"
    if data
      if data.is_a? Hash
        data = RSolr::Uri.params_to_solr data
        headers['Content-Type'] ||= 'application/x-www-form-urlencoded'
      end
    end
    opts.merge({
      :uri => request_uri,
      :data => data,
      :headers => headers,
      :query_string => query_string,
      :client => self
    })
  end
  
  # This method will evaluate the :body value
  # if the params[:uri].params[:wt] == :ruby
  # ... otherwise, the body is returned as is.
  # The return object has a special method attached called #context.
  # This method gives you access to the original
  # request and response from the connection.
  # This method will raise an InvalidRubyResponse
  # if the :wt => :ruby and the body
  # couldn't be evaluated.
  def adapt_response request, response
    raise ValidationError.new("The response does not have the correct keys => :body, :headers, :status") unless %W(body headers status) == response.keys.map{|k|k.to_s}.sort
    raise RSolr::Error::Http.new(request, response) unless [200,302].include?(response[:status])
    data = response[:body]
    if request[:params][:wt] == :ruby
      begin
        data = Kernel.eval data.to_s
      rescue SyntaxError
        raise RSolr::Error::InvalidRubyResponse.new(request, response)
      end
    end
    data.extend Module.new.instance_eval{attr_accessor :request, :response; self}
    data.request = request
    data.response = response
    data
  end
  
end