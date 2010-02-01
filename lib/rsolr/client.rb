class RSolr::Client
  
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
    request("/#{method_name}", *args, &blk)
  end
  
  # sends data to the update handler
  # data can be a string of xml, or an object that returns xml from its #to_xml method
  def update(data, params={})
    request '/update', params, data
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
    response = @connection.request(path, map_params(params), *extra)
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

  # send </commit>
  def commit
    update message.commit
  end

  # send </optimize>
  def optimize
    update message.optimize
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
  def message *opts
    @message ||= RSolr::Message::Generator.new
  end
  
  protected
  
  # sets default params etc.. - could be used as a mapping hook
  # type of request should be passed in here? -> map_params(:query, {})
  def map_params(params)
    params||={}
    {:wt=>:ruby}.merge(params)
  end

  # "connection_response" must be a hash with the following keys:
  #   :params - a sub hash of standard solr params
  #   : body - the raw response body from the solr server
  # This method will evaluate the :body value if the params[:wt] == :ruby
  # otherwise, the body is returned
  # The return object has a special method attached called #raw
  # This method gives you access to the original response from the connection,
  # so you can access things like the actual :url sent to solr,
  # the raw :body, original :params and original :data
  def adapt_response(connection_response)
    data = connection_response[:body]
    # if the wt is :ruby, evaluate the ruby string response
    if connection_response[:params][:wt] == :ruby
      data = Kernel.eval(data)
    end
    # attach a method called #raw that returns the original connection response value
    def data.raw; @raw end
    data.send(:instance_variable_set, '@raw', connection_response)
    data
  end
  
end