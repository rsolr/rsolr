class RSolr::Client
  
  attr_reader :connection
  
  def initialize connection
    @connection = connection
  end
  
  # GET request
  def get path, params = nil, headers = nil
    send_request :get, path, params, nil, headers
  end
  
  # essentially a GET, but no response body
  def head path, params = nil, headers = nil
    send_request :head, path, params, nil, headers
  end
  
  # post, solr doesn't do headers on POST
  def post path, data, params = nil
    send_request :post, path, params, data, nil
  end
  
  # POST to /update with optional params
  def update data, params = nil
    post 'update', data, params
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
    uri, data, headers = build_request path, params, data, headers
    begin
      response = data ? connection.send(method, uri, data, headers) : connection.send(method, uri, headers)
      raise "Error: #{response[0]}" if response[0] != 200
      response
    rescue
      $!.extend(Module.new{ attr_accessor :solr_context }).solr_context = {
        :connection => connection,
        :method => method,
        :uri => uri,
        :data => data,
        :params => params,
        :headers => headers
      }
      raise $!
    end
  end
  
  def build_request path, params, data, headers
    params ||= {}
    headers ||= {}
    request_uri = "#{path}?#{RSolr::Uri.params_to_solr params}"
    if data
      if data.is_a?(Hash)
        data = RSolr::Uri.params_to_solr data
        headers['Content-Type'] ||= 'application/x-www-form-urlencoded'
      else
        headers['Content-Type'] ||= 'text/xml'
      end
    end
    [request_uri, data, headers]
  end
  
end