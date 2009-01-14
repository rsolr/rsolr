#
# Connection adapter decorator
#
class RSolr::Connection::Base
  
  attr_reader :adapter, :opts
  
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
    {}.merge(@opts[:global_params]).merge(params).to_mash
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
  
  # same as the #query method, but with additional param mapping
  # currently only :page and :per_page
  # TODO: need to get some nice and friendly param mapping here:
  # search(:fields=>'', :facet_fields=>[], :filters=>{})
  def search(params)
    self.query(modify_params_for_pagination(params))
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
  
  # given a hash, this method will attempt to produce the
  # correct :start and :rows values for Solr
  # -- if the hash contains a :per_page value, it's used for the rows
  # if the :per_page value doesn't exist (nil), the :rows value is
  # used, and if :rows is not set, the default value is 10
  # -- if the hash contains a :page value (the current page)
  # it is used to calculate the :start value
  # returns a hash with the :rows and :start values
  # :per_page and :page are deleted
  def modify_params_for_pagination(p)
    per_page = p.delete(:per_page).to_s.to_i
    p[:rows] = per_page==0 ? (p[:rows] || 10) : per_page
    page = p.delete(:page).to_s.to_i
    page = page > 0 ? page : 1
    p[:start] = (page - 1) * (p[:rows] || 0)
    p
  end
  
end