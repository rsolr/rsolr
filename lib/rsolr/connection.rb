class RSolr::Connection
  
  attr_reader :adapter, :opts
  
  # "adapter" is instance of:
  #   RSolr::Adapter::HTTP
  #   RSolr::Adapter::Direct (jRuby only)
  def initialize(adapter, opts={})
    @adapter = adapter
    @opts = opts
  end
  
  # send a request to the "select" handler
  def select(params, &blk)
    send_request('/select', map_params(params), &blk)
  end
  
  # sends a request to the admin luke handler to get info on the index
  def index_info(params={}, &blk)
    params[:numTerms] ||= 0
    send_request('/admin/luke', map_params(params), &blk)
  end
  
  # sends data to the update handler
  # data can be a string of xml, or an object that returns xml from its #to_s method
  def update(data, params={}, &blk)
    send_request('/update', map_params(params), data, &blk)
  end
  
  # send request solr
  # params is hash with valid solr request params (:q, :fl, :qf etc..)
  #   if params[:wt] is not set, the default is :ruby
  #   if :wt is something other than :ruby, the raw response body is used
  #   otherwise, a simple Hash is returned
  #   NOTE: to get raw ruby, use :wt=>'ruby' <- a string, not a symbol like :ruby  
  # 
  # use a block to get access to the adapter response:
  # solr.send_request('/select', :q=>'blue') do |solr_response, adapter_response|
  #   raise 'Woops!' if adapter_response[:status] != 200
  #   solr_response[:response][:docs].each {|doc|}
  # end
  #
  def send_request(path, params={}, data=nil, &blk)
    response = @adapter.send_request(path, map_params(params), data)
    adapt_response(response, &blk)
  end
  
  # 
  # single record:
  # solr.update(:id=>1, :name=>'one')
  #
  # update using an array
  # solr.update([{:id=>1, :name=>'one'}, {:id=>2, :name=>'two'}])
  #
  def add(doc, &block)
    update message.add(doc, &block)
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
  
  # 
  def adapt_response(adapter_response)
    if adapter_response[:params][:wt] == :ruby
      data = Kernel.eval(adapter_response[:body]).to_mash
    else
      data = adapter_response[:body]
    end
    block_given? ? yield(data, adapter_response) : data
  end
  
end