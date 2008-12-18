# This module is for HTTP + DirectSolrConnection (jruby) connections
# It provides common methods.
# The main query, update and index_info methods are here
# The classes that include this module only need to provide a request method like:
#   send_request(request_path, params, data)
# where:
#   request_path is a string to a handler (/select)
#   params is a hash for query string params
#   data is optional string of xml
module Solr::Adapter::CommonMethods
  
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
    params = map_params(params)
    @adapter.send_request(handler_path, params, data)
  end
  
  # escapes a query key/value for http
  def escape(s)
    s.to_s.gsub(/([^ a-zA-Z0-9_.-]+)/n) {
      '%'+$1.unpack('H2'*$1.size).join('%').upcase
    }.tr(' ', '+') 
  end
  
  def build_param(k,v)
    "#{escape(k)}=#{escape(v)}"
  end
  
  # takes a path and a hash of query params, returns an escaped url with query params
  def build_url(path, params_hash=nil)
    query = hash_to_params(params_hash)
    query ? path + '?' + query : path
  end
  
  #
  # converts hash into URL query string, keys get an alpha sort
  # if a value is an array, the array values get mapped to the same key:
  #   hash_to_params(:q=>'blah', 'facet.field'=>['location_facet', 'format_facet'])
  # returns:
  #   ?q=blah&facet.field=location_facet&facet.field=format.facet
  #
  # if a value is empty/nil etc., the key is not added
  def hash_to_params(params)
    return unless params.is_a?(Hash)
    # copy params and convert keys to strings
    params = params.inject({}){|acc,(k,v)| acc.merge({k.to_s, v}) }
    # get sorted keys
    params.keys.sort.inject([]) do |acc,k|
      v = params[k]
      if v.is_a?(Array)
        acc << v.reject{|i|i.to_s.empty?}.collect{|vv|build_param(k, vv)}
      elsif ! v.to_s.empty?
        acc.push(build_param(k, v))
      end
      acc
    end.join('&')
  end
  
end