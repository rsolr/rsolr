# A simple wrapper for different http client implementations.
# Supports #get and #post
# This was motivated by: http://apocryph.org/2008/11/09/more_indepth_analysis_ruby_http_client_performance/

# Each adapters' response should be a hash with the following keys:
#   :status_code
#   :url
#   :body
#   :path
#   :params
#   :data
#   :headers

# Example:
#   hclient = RSolr::HTTPClient.connect('http://www.google.com')
#   # SAME AS
#   hclient = RSolr::HTTPClient.connect(:net_http, 'http://www.google.com')
#   hclient = RSolr::HTTPClient.connect(:curb, 'http://www.google.com')
#   response = hclient.get('/search', :hl=>:en, :q=>:ruby, :btnG=>:Search)
#   puts response[:status_code]
#   puts response[:body]

require 'uri'

module RSolr::HTTPClient
  
  module Adapter
    autoload :Curb, 'rsolr/http_client/adapter/curb'
    autoload :NetHTTP, 'rsolr/http_client/adapter/net_http'
  end
  
  class UnkownAdapterError < RuntimeError
  end
  
  # Factory for creating connections.
  # Can specify the connection type by
  # using :net_http or :curb for the first argument.
  # The ending arguments are always used for the connection adapter instance.
  #
  # Examples:
  # # default net_http connection
  # RSolr::HTTPClient.connect :url=>''
  # # SAME AS
  # RSolr::HTTPClient.connect :net_http, :url=>''
  # # curb connection
  # RSolr.connect :curb, :url=>''
  def self.connect(*args)
    type = args.first.is_a?(Symbol) ? args.shift : :net_http
    opts = args
    klass = case type
    when :net_http,nil
      'NetHTTP'
    when :curb
      'Curb'
    else
      raise UnkownAdapterError.new("Invalid adapter type: #{type} - use :curb or :net_http or blank for :net_http/default")
    end
    begin
      Base.new Adapter.const_get(klass).new(*args)
    end
  end
  
  # The base class for interacting with one of the HTTP client adapters
  class Base
    
    attr_reader :adapter
    
    # requires an instace of RSolr::HTTPClient::*
    def initialize(adapter)
      @adapter = adapter
    end
    
    # sends a GET reqest to the "path" variable
    # an optional hash of "params" can be used,
    # which is later transformed into a GET query string
    def get(path, params={})
      begin
        http_context = @adapter.get(path, params)
      rescue
        raise RSolr::RequestError.new($!)
      end
      http_context
    end
    
    # sends a POST request to the "path" variable
    # "data" is required, and must be a string
    # "params" is an optional hash for query string params...
    # "headers" is a hash for setting request header values.
    def post(path, data, params={}, headers={})
      begin
        http_context = @adapter.post(path, data, params, headers)
      rescue
        raise RSolr::RequestError.new($!)
      end
      http_context
    end
    
  end
  
  module Util
    
    # escapes a query key/value for http
    def escape(s)
      s.to_s.gsub(/([^ a-zA-Z0-9_.-]+)/n) {
        '%'+$1.unpack('H2'*$1.size).join('%').upcase
      }.tr(' ', '+') 
    end
    
    # creates and returns a url as a string
    # "url" is the base url
    # "params" is an optional hash of GET style query params
    # "string_query" is an extra query string that will be appended to the 
    # result of "url" and "params".
    def build_url(url='', params={}, string_query='')
      queries = [string_query, hash_to_params(params)]
      queries.delete_if{|i| i.to_s.empty?}
      url += "?#{queries.join('&')}" unless queries.empty?
      url
    end
    
    # converts a key value pair to an escaped string:
    # Example:
    # build_param(:id, 1) == "id=1"
    def build_param(k,v)
      "#{escape(k)}=#{escape(v)}"
    end
    
    #
    # converts hash into URL query string, keys get an alpha sort
    # if a value is an array, the array values get mapped to the same key:
    #   hash_to_params(:q=>'blah', :fq=>['blah', 'blah'], :facet=>{:field=>['location_facet', 'format_facet']})
    # returns:
    #   ?q=blah&fq=blah&fq=blah&facet.field=location_facet&facet.field=format.facet
    #
    # if a value is empty/nil etc., the key is not added
    def hash_to_params(params)
      return unless params.is_a?(Hash)
      # copy params and convert keys to strings
      params = params.inject({}){|acc,(k,v)| acc.merge(k.to_s => v) }
      # get sorted keys
      params.keys.sort.inject([]) do |acc,k|
        v = params[k]
        if v.is_a?(Array)
          acc << v.reject{|i|i.to_s.empty?}.collect{|vv|build_param(k, vv)}
        elsif v.is_a?(Hash)
          # NOT USED
          # creates dot based params like:
          # hash_to_params(:facet=>{:field=>['one', 'two']}) == facet.field=one&facet.field=two
          # TODO: should this go into a non-solr based param builder?
          #   - dotted syntax is special to solr only
          #v.each_pair do |field,field_value|
          #  acc.push(hash_to_params({"#{k}.#{field}"=>field_value}))
          #end
        elsif ! v.to_s.empty?
          acc.push(build_param(k, v))
        end
        acc
      end.join('&')
    end
    
  end
  
end
