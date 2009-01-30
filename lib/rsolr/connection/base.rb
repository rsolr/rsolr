#
# Connection adapter decorator
#
class RSolr::Connection::Base
  
  attr_reader :adapter, :opts
  
  attr_accessor :param_mappers
  
  # "adapter" is instance of:
  #   RSolr::Adapter::HTTP
  #   RSolr::Adapter::Direct (jRuby only)
  def initialize(adapter, opts={})
    @adapter = adapter
    @param_mappers = {
      :standard=>RSolr::Connection::ParamMapping::Standard,
      :dismax=>RSolr::Connection::ParamMapping::Dismax
    }
    opts[:global_params]||={}
    default_global_params = {
      :wt=>:ruby,
      :echoParams=>'EXPLICIT',
      :debugQuery=>true
    }
    opts[:global_params] = default_global_params.merge(opts[:global_params])
    @opts = opts
  end
  
  # sets default params etc.. - could be used as a mapping hook
  # type of request should be passed in here? -> map_params(:query, {})
  def map_params(params)
    {}.merge(@opts[:global_params]).merge(params)
  end
  
  # send request (no param mapping) to the select handler
  # params is hash with valid solr request params (:q, :fl, :qf etc..)
  #   if params[:wt] is not set, the default is :ruby (see opts[:global_params])
  #   if :wt is something other than :ruby, the raw response body is returned
  #   otherwise, an instance of RSolr::Response::Query is returned
  #   NOTE: to get raw ruby, use :wt=>'ruby'
  # There is NO param mapping here, what you put it is what gets sent to Solr
  def query(params)
    p = map_params(params)
    response = @adapter.query(p)
    p[:wt]==:ruby ? RSolr::Response::Query::Base.new(response) : response
  end
  
  # The #search method uses a param mapper to prepare the request for solr.
  # For example, instead of doing your fq params by hand,
  # you can use the simplified :filters param instead.
  # The 2 built in mappers are for dismax and standard: RSolr::Connection::ParamMapping::*
  # The default is :dismax
  # If you create your own request handler in solrconfig.xml,
  # you can use it by setting the :qt=>:my_handler
  # You'll need to set the correct param mapper class (when using the search method)
  # To take advantage of the param mapping
  # If your request handler uses the solr dismax class, then do nothing
  # if it uses the standard, you'll need to set it like:
  # solr.param_mappers[:my_search_handler] = :standard
  # The value can also be a custom class constant that must have a #map method
  # The initialize method must accept a hash of input params
  # The #map method must handle a block being passed in and return a new hash of raw solr params
  def search(params,&blk)
    qt = params[:qt] ? params[:qt].to_sym : :dismax
    mapper_class = @param_mappers[qt]
    mapper_class = RSolr::Connection::ParamMapping::Dismax if mapper_class==:dismax
    mapper_class = RSolr::Connection::ParamMapping::Standard if mapper_class==:standard
    mapper = mapper_class.new(params)
    query(mapper.map(&blk))
  end
  
  # "facet_field" -- the name of a facet field: language_facet
  # "params" -- the standard #search method params
  # Returns an instance of RSolr::Response::Query::Base
  def search_facet_by_name(facet_field, params, &blk)
    params[:per_page] = 0
    params[:rows] = 0
    params[:facets] ||= {}
    params[:facets][:fields] = [facet_field]
    params[:facets][:mincount] ||= 1
    params[:facets][:prefix] ||= nil
    params[:facets][:missing] ||= false
    params[:facets][:sort] ||= :count
    params[:facets][:offset] ||= 0
    self.search(params, &blk)
  end
  
  # Finds a document by its id
  def find_by_id(id, params={})
    params = map_params(params)
    params[:q] = 'id:"#{id}"'
    query params
  end
  
  def index_info(params={})
    params = map_params(params)
    response = @adapter.index_info(params)
    params[:wt] == :ruby ? RSolr::Response::IndexInfo.new(response) : response
  end
  
  # if :ruby is the :wt, then Solr::Response::Base is returned
  # -- there's not really a way to figure out what kind of handler request this is.
  
  def update(data, params={})
    params = map_params(params)
    response = @adapter.update(data, params)
    params[:wt]==:ruby ? RSolr::Response::Update.new(response) : response
  end
  
  def add(hash_or_array, opts={}, &block)
    update message.add(hash_or_array, opts, &block)
  end
  
  # send </commit>
  def commit(opts={})
    update message.commit, opts
  end
  
  # send </optimize>
  def optimize(opts={})
    update message.optimize, opts
  end
  
  # send </rollback>
  # NOTE: solr 1.4 only
  def rollback(opts={})
    update message.rollback, opts
  end
  
  # Delete one or many documents by id
  #   solr.delete_by_id 10
  #   solr.delete_by_id([12, 41, 199])
  def delete_by_id(ids, opts={})
    update message.delete_by_id(ids), opts
  end
  
  # delete one or many documents by query
  #   solr.delete_by_query 'available:0'
  #   solr.delete_by_query ['quantity:0', 'manu:"FQ"']
  def delete_by_query(queries, opts={})
    update message.delete_by_query(queries), opts
  end
  
  protected
  
  # shortcut to solr::message
  def message
    RSolr::Message
  end
  
end