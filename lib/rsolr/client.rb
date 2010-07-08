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
  
  def method_missing name, *args
    send_request name, *args
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
  #   :add_attributes => {:boost=>5.0, :commitWithin=>10}
  # )
  # 
  def add doc, opts = {}
    add_attributes = opts.delete :add_attributes
    update opts.merge(:data => xml.add(doc, add_attributes))
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
  def commit opts = {}
    commit_attrs = opts.delete :commit_attributes
    update opts.merge(:data => xml.commit( commit_attrs ))
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
    optimize_attributes = opts.delete :optimize_attributes
    update opts.merge(:data => xml.optimize(optimize_attributes))
  end
  
  # send </rollback>
  # NOTE: solr 1.4 only
  def rollback opts = {}
    update opts.merge(:data => xml.rollback)
  end

  # Delete one or many documents by id
  #   solr.delete_by_id 10
  #   solr.delete_by_id([12, 41, 199])
  def delete_by_id id, opts = {}
    update opts.merge(:data => xml.delete_by_id(id))
  end

  # delete one or many documents by query
  #   solr.delete_by_query 'available:0'
  #   solr.delete_by_query ['quantity:0', 'manu:"FQ"']
  def delete_by_query query, opts = {}
    update opts.merge(:data => xml.delete_by_query(query))
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
  # +send_request+ returns either a string or hash on a successful ruby request.
  # When the :params[:wt] => :ruby, the response will be a hash, else a string.
  # 
  def send_request path, opts = {}
    connection.send_request path, opts
  end
  
  # used for debugging/inspection
  # - accepts the same args as send_request
  def build_request path, opts = {}
    connection.build_request path, opts
  end
  
  # used for debugging/inspection
  # - accepts the same args as send_request
  def adapt_response request_context, response
    connection.adapt_response request_context, response
  end
  
end