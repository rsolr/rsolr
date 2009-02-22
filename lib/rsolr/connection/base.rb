#
# Connection adapter decorator
#
class RSolr::Connection::Base
  
  attr_reader :adapter, :opts
  
  # "adapter" is instance of:
  #   RSolr::Adapter::HTTP
  #   RSolr::Adapter::Direct (jRuby only)
  def initialize(adapter, opts={})
    @adapter = adapter
    @opts = opts
  end
  
  # send request (no param mapping) to the select handler
  # params is hash with valid solr request params (:q, :fl, :qf etc..)
  #   if params[:wt] is not set, the default is :ruby (see opts[:global_params])
  #   if :wt is something other than :ruby, the raw response body is returned
  #   otherwise, an instance of RSolr::Response::Query is returned
  #   NOTE: to get raw ruby, use :wt=>'ruby'
  # There is NO param mapping here, what you put it is what gets sent to Solr
  def query(*args)
    params = map_params(args.extract_options!)
    args << params
    response = @adapter.query(*args)
    params[:wt] == :ruby ? RSolr::Response::Query::Base.new(response) : response
  end
  
  # Finds a document by its id
  def find_by_id(*args)
    params = map_params(args.extract_options!)
    params[:q] = 'id:"#{id}"'
    args << params
    self.query(*args)
  end
  
  # 
  def update(*args)
    params = map_params(args.extract_options!)
    args << params
    response = @adapter.update(*args)
    params[:wt] == :ruby ? RSolr::Response::Update.new(response) : response
  end
  
  def index_info(*args)
    params = map_params(args.extract_options!)
    args << params
    response = @adapter.index_info(*args)
    params[:wt] == :ruby ? RSolr::Response::IndexInfo.new(response) : response
  end
  
  def add(*args, &block)
    update message.add(*args, &block)
  end
  
  # send </commit>
  def commit(*args)
    update message.commit, *args
  end
  
  # send </optimize>
  def optimize(*args)
    update message.optimize, *args
  end
  
  # send </rollback>
  # NOTE: solr 1.4 only
  def rollback(*args)
    update message.rollback, *args
  end
  
  # Delete one or many documents by id
  #   solr.delete_by_id 10
  #   solr.delete_by_id([12, 41, 199])
  def delete_by_id(*args)
    update message.delete_by_id(args.shift), *args
  end
  
  # delete one or many documents by query
  #   solr.delete_by_query 'available:0'
  #   solr.delete_by_query ['quantity:0', 'manu:"FQ"']
  def delete_by_query(*args)
    update message.delete_by_query(args.shift), *args
  end
  
  protected
  
  # shortcut to solr::message
  def message
    RSolr::Message
  end
  
  # sets default params etc.. - could be used as a mapping hook
  # type of request should be passed in here? -> map_params(:query, {})
  def map_params(params)
    params||={}
    {:wt=>:ruby}.merge(params)
  end
  
end