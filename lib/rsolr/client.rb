class RSolr::Client
  
  include RSolr::Char
  
  attr_reader :connection
  
  # "connection" is instance of:
  #   RSolr::Adapter::HTTP
  #   RSolr::Adapter::Direct (jRuby only)
  # or any other class that uses the connection "interface"
  def initialize(connection)
    @connection = connection
  end
  
  # Send a request to a request handler using the method name.
  # Also proxies to the #paginate method if the method starts with "paginate_"
  def method_missing(method_name, *args, &blk)
    request("#{method_name}", *args, &blk)
  end
  
  # sends data to the update handler
  # data can be a string of xml, or an object that returns xml from its #to_xml method
  def update(data, params={})
    request 'update', map_params(params), data
  end
  
  # send request solr
  # params is hash with valid solr request params (:q, :fl, :qf etc..)
  #   if params[:wt] is not set, the default is :ruby
  #   if :wt is something other than :ruby, the raw response body is used
  #   otherwise, a simple Hash is returned
  #   NOTE: to get raw ruby, use :wt=>'ruby' <- a string, not a symbol like :ruby  
  #
  #
  def request(path, params={}, *extra)
    response = @connection.request(path.to_s, map_params(params), *extra)
    adapt_response(response)
  end
  
  # 
  # single record:
  # solr.update(:id=>1, :name=>'one')
  #
  # update using an array
  # solr.update([{:id=>1, :name=>'one'}, {:id=>2, :name=>'two'}])
  #
  def add(doc, params={}, &block)
    update message.add(doc, params, &block)
  end

  # send "commit" message with options
  #
  # Options recognized by solr
  #
  #   :maxSegments    => N - optimizes down to at most N number of segments
  #   :waitFlush      => true|false - do not return until changes are flushed to disk
  #   :waitSearcher   => true|false - do not return until a new searcher is opened and registered
  #   :expungeDeletes => true|false - merge segments with deletes into other segments #NOT
  #
  # *NOTE* :expungeDeletes is Solr 1.4 only
  #
  def commit( options = {} )
    update message.commit( options )
  end

  # send "optimize" message with options.
  #
  # Options recognized by solr
  #
  #   :maxSegments    => N - optimizes down to at most N number of segments
  #   :waitFlush      => true|false - do not return until changes are flushed to disk
  #   :waitSearcher   => true|false - do not return until a new searcher is opened and registered
  #   :expungeDeletes => true|false - merge segments with deletes into other segments
  #
  # *NOTE* :expungeDeletes is Solr 1.4 only
  #
  def optimize( options = {} )
    update message.optimize( options )
  end

  # send </rollback>
  # NOTE: solr 1.4 only
  def rollback
    update message.rollback
  end

  # Delete one or many documents by id
  #   solr.delete_by_id 10
  #   solr.delete_by_id([12, 41, 199])
  def delete_by_id(id)
    update message.delete_by_id(id)
  end

  # delete one or many documents by query
  #   solr.delete_by_query 'available:0'
  #   solr.delete_by_query ['quantity:0', 'manu:"FQ"']
  def delete_by_query(query)
    update message.delete_by_query(query)
  end
  
  # shortcut to RSolr::Message::Generator
  def message
    @message ||= RSolr::Message::Generator.new
  end
  
  protected
  
  # sets default params etc.. - could be used as a mapping hook
  # type of request should be passed in here? -> map_params(:query, {})
  def map_params(params)
    params||={}
    {:wt=>:ruby}.merge(params)
  end
  
  # Thrown if the :wt is :ruby
  # but the body wasn't succesfully parsed.
  class InvalidRubyResponse < RuntimeError
    include RSolr::Contextable
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
  def adapt_response context
    data = context[:response][:body]
    if context[:request][:uri].params[:wt] == :ruby
      begin
        data = Kernel.eval data
      rescue SyntaxError
        raise InvalidRubyResponse.new(context)
      end
    end
    data.extend RSolr::Contextable
    data.context = context
    data
  end
  
end