#
# Connection adapter decorator
#
class RSolr::Connection::Base
  
  attr_reader :adapter, :opts
  
  include RSolr::Connection::SearchExt
  
  # "adapter" is instance of:
  #   RSolr::Adapter::HTTP
  #   RSolr::Adapter::Direct (jRuby only)
  def initialize(adapter, opts={})
    @adapter=adapter
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
    opts[:global_params].dup.merge(params).to_mash
  end
  
  # send request to the select handler
  # params is hash with valid solr request params (:q, :fl, :qf etc..)
  #   if params[:wt] is not set, the default is :ruby (see opts[:global_params])
  #   if :wt is something other than :ruby, the raw response body is returned
  #   otherwise, an instance of RSolr::Response::Query is returned
  #   NOTE: to get raw ruby, use :wt=>'ruby'
  def query(params)
    params = map_params(modify_params_for_pagination(params))
    response = @adapter.query(params)
    params[:wt]==:ruby ? RSolr::Response::Query::Base.new(response) : response
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
  
  def modify_params_for_pagination(orig_params)
    return orig_params unless orig_params[:page] || orig_params[:per_page]
    params = orig_params.dup # be nice
    params[:page] ||= 1
    params[:per_page] ||= 10
    params[:rows] = params.delete(:per_page).to_i
    params[:start] = calculate_start(params.delete(:page).to_i, params[:rows])
    params
  end
  
  def calculate_start(current_page, per_page)
    page = current_page > 0 ? current_page : 1
    (page - 1) * per_page
  end
  
end