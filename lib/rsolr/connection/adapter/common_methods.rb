# This module is for HTTP + DirectSolrConnection (jruby) connections
# It provides common methods.
# The main query, update and index_info methods are here
# The classes that include this module only need to provide a request method like:
#   send_request(request_path, params, data)
# where:
#   request_path is a string to a handler (/select)
#   params is a hash for query string params
#   data is optional string of xml
module RSolr::Connection::Adapter::CommonMethods
  
  # send a request to the "select" handler
  def query(params)
    send_request @opts[:select_path], params
  end
  
  # sends data to the update handler
  # data can be:
  #   string (valid solr update xml)
  #   object with respond_to?(:to_xml)
  # params is a hash with valid solr update params
  def update(data, params={})
    send_request @opts[:update_path], params, data
  end
  
  # sends a request to the admin luke handler to get info on the index
  def index_info(params={})
    params[:numTerms]||=0
    send_request @opts[:luke_path], params
  end
  
  def default_options
    {
      :select_path => '/select',
      :update_path => '/update',
      :luke_path => '/admin/luke'
    }
  end
  
  # send a request to the adapter (allows requests like /admin/luke etc.)
  def send_request(handler_path, params={}, data=nil)
    @adapter.send_request(handler_path, params, data)
  end
  
end