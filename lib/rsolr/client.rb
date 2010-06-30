class RSolr::Client
  
  attr_reader :connection
  
  def initialize connection
    @connection = connection
  end
  
  # GET request
  def get path = '', params = nil, headers = nil
    send_request :get, path, params, nil, headers
  end
  
  # essentially a GET, but no response body
  def head path = '', params = nil, headers = nil
    send_request :head, path, params, nil, headers
  end
  
  # A path is required for a POST since, well...
  # the / resource doesn't do anything with a POST.
  # Also, Solr doesn't do headers with a POST
  def post path, data = nil, params = nil, headers = nil
    send_request :post, path, params, data, headers
  end
  
  # POST XML messages to /update with optional params
  def update data, params = {}, headers = {}
    headers['Content-Type'] ||= 'text/xml'
    post 'update', data, params, headers
  end
  
  # 
  # single record:
  # solr.update(:id=>1, :name=>'one')
  #
  # update using an array
  # solr.update([{:id=>1, :name=>'one'}, {:id=>2, :name=>'two'}])
  #
  def add(doc, params={}, &block)
    update xml.add(doc, params, &block)
  end

  # send "commit" xml with options
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
    update xml.commit( options )
  end

  # send "optimize" xml with options.
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
    update xml.optimize( options )
  end

  # send </rollback>
  # NOTE: solr 1.4 only
  def rollback
    update xml.rollback
  end

  # Delete one or many documents by id
  #   solr.delete_by_id 10
  #   solr.delete_by_id([12, 41, 199])
  def delete_by_id(id)
    update xml.delete_by_id(id)
  end

  # delete one or many documents by query
  #   solr.delete_by_query 'available:0'
  #   solr.delete_by_query ['quantity:0', 'manu:"FQ"']
  def delete_by_query(query)
    update xml.delete_by_query(query)
  end
  
  # shortcut to RSolr::Message::Generator
  def xml
    @xml ||= RSolr::Xml::Generator.new
  end
  
  def send_request method, path, params, data, headers
    params = map_params params
    uri, data, headers = build_request path, params, data, headers
    request_context = {:connection=>connection, :method => method, :uri => uri, :data => data, :headers => headers, :params => params}
    begin
      response = data ? connection.send(method, uri, data, headers) : connection.send(method, uri, headers)
    rescue
     $!.extend(RSolr::Error::SolrContext).request = request_context
     raise $!
    end
    raise "The connection adapter returned an unexpected object" unless response.is_a?(Hash)
    raise RSolr::Error::Http.new request_context, response unless [200,302].include?(response[:status])
    adapt_response request_context, response
  end
  
  def map_params params
    params = params.nil? ? {} : params.dup
    params[:wt] ||= :ruby
    params
  end
  
  def build_request path, params, data, headers
    params ||= {}
    headers ||= {}
    request_uri = params.any? ? "#{path}?#{RSolr::Uri.params_to_solr params}" : path
    if data
      if data.is_a? Hash
        data = RSolr::Uri.params_to_solr data
        headers['Content-Type'] ||= 'application/x-www-form-urlencoded'
      end
    end
    [request_uri, data, headers]
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
    data = response[:body]
    if request[:params][:wt] == :ruby
      begin
        data = Kernel.eval data.to_s
      rescue SyntaxError
        raise RSolr::Error::InvalidRubyResponse.new request, response
      end
    end
    data.extend Module.new.instance_eval{attr_accessor :request, :response; self}
    data.request = request
    data.response = response
    data
  end
  
end