# This module is for HTTP + DirectSolrConnection (jruby) connections
# It provides common methods.
# The main query, update and index_info methods are here
# The classes that include this module only need to provide a request method like:
#   send_request(request_path, params, data)
# where:
#   request_path is a string to a handler (/select etc.)
#   params is a hash for query string params
#   data is optional string of xml
module RSolr::Connection::Adapter::CommonMethods
  
  # send a request to the "select" handler
  # the first argument is the select handler path
  # the last argument is a hash of params
  def query(*args)
    params = args.extract_options!
    path = args.first || @opts[:select_path]
    self.send_request "/#{path}", params
  end
  
  # sends a request to the admin luke handler to get info on the index
  # the first argument is the admin/luke request handler path
  # the last argument is a hash of params
  def index_info(*args)
    params = args.extract_options!
    path = args.first || @opts[:luke_path]
    params[:numTerms]||=0
    self.send_request "/#{path}", params
  end
  
  # sends data to the update handler
  # If 2 arguments are passed in:
  #   - the first should be the POST data string
  #   - the second can be an optional url params hash
  #   - the path is defaulted to '/update'
  # If 3 arguments are passed in:
  #   - the first argument should be the url path ('/my-update-handler' etc.)
  #   - the second should be the POST data string
  #   - the last/third should be an optional url params hash
  # data can be:
  #   string (valid solr update xml)
  #   object with respond_to?(:to_xml)
  def update(*args)
    params = args.extract_options!
    data = args.last
    path = args.size == 2 ? args.first : @opts[:update_path]
    self.send_request "/#{path}", params, data
  end
  
end