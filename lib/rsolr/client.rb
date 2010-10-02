class RSolr::Client
  
  attr_reader :connection
  
  def initialize connection
    @connection = connection
  end
  
  # Create the get, post, and head methods
  %W(get post head).each do |meth|
    class_eval <<-RUBY
    def #{meth} path, opts = {}, &block
      send_and_receive path, opts.merge(:method => :#{meth}), &block
    end
    RUBY
  end
  
  # converts the method name for the solr request handler path.
  def method_missing name, *args
    send_and_receive name, *args
  end
  
  # POST XML messages to /update with optional params.
  # 
  # http://wiki.apache.org/solr/UpdateXmlMessages#add.2BAC8-update
  #
  # If not set, opts[:headers] will be set to a hash with the key
  # 'Content-Type' set to 'text/xml'
  #
  # +opts+ can/should contain:
  #
  #  :data - posted data
  #  :headers - http headers
  #  :params - solr query parameter hash
  #
  def update opts = {}
    opts[:headers] ||= {}
    opts[:headers]['Content-Type'] ||= 'text/xml'
    post 'update', opts
  end
  
  # 
  # +add+ creates xml "add" documents and sends the xml data to the +update+ method
  # 
  # http://wiki.apache.org/solr/UpdateXmlMessages#add.2BAC8-update
  # 
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
  # http://wiki.apache.org/solr/UpdateXmlMessages#A.22commit.22_and_.22optimize.22
  #
  def commit opts = {}
    commit_attrs = opts.delete :commit_attributes
    update opts.merge(:data => xml.commit( commit_attrs ))
  end

  # send "optimize" xml with opts.
  #
  # http://wiki.apache.org/solr/UpdateXmlMessages#A.22commit.22_and_.22optimize.22
  #
  def optimize opts = {}
    optimize_attributes = opts.delete :optimize_attributes
    update opts.merge(:data => xml.optimize(optimize_attributes))
  end
  
  # send </rollback>
  # 
  # http://wiki.apache.org/solr/UpdateXmlMessages#A.22rollback.22
  # 
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

  # delete one or many documents by query.
  # 
  # http://wiki.apache.org/solr/UpdateXmlMessages#A.22delete.22_by_ID_and_by_Query
  # 
  #   solr.delete_by_query 'available:0'
  #   solr.delete_by_query ['quantity:0', 'manu:"FQ"']
  def delete_by_query query, opts = {}
    update opts.merge(:data => xml.delete_by_query(query))
  end
  
  # shortcut to RSolr::Message::Generator
  def xml
    @xml ||= RSolr::Xml::Generator.new
  end
  
  # +send_and_receive+ is the main request method responsible for sending requests to the +connection+ object.
  # 
  # "path" : A string value that usually represents a solr request handler
  # "opt" : A hash, which can contain the following keys:
  #   :method : required - the http method (:get, :post or :head)
  #   :params : optional - the query string params in hash form
  #   :data : optional - post data -- if a hash is given, it's sent as "application/x-www-form-urlencoded"
  #   :headers : optional - hash of request headers
  # All other options are passed right along to the connection's +send_and_receive+ method (:get, :post, or :head)
  # 
  # +send_and_receive+ returns either a string or hash on a successful ruby request.
  # When the :params[:wt] => :ruby, the response will be a hash, else a string.
  # 
  def send_and_receive path, opts = {}
    connection.send_and_receive path, opts
  end
  
  # used for debugging/inspection
  # - accepts the same args as send_and_receive
  def build_request path, opts = {}
    connection.build_request path, opts
  end
  
  # used for debugging/inspection
  # - accepts the same args as send_and_receive
  def adapt_response request_context, response
    connection.adapt_response request_context, response
  end
  
end