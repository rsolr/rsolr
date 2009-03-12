# A simple wrapper for different http client implementations.
# Supports #get and #post
# This was motivated by: http://apocryph.org/2008/11/09/more_indepth_analysis_ruby_http_client_performance/
# Curb is the default adapter

# Each adapters response should be a hash with the following keys:
#   :status_code
#   :url
#   :body
#   :path
#   :params
#   :data
#   :headers

# Example:
#   connector = RSolr::HTTPClient.Connector.new
#   connector.adapter_name = :net_http # switch to Net::HTTP before calling "connect"
#   hclient = connector.connect('http://www.google.com')
#   response = hclient.get('/search', :hl=>:en, :q=>:ruby, :btnG=>:Search)
#   puts response[:status_code]
#   puts response[:body]

require 'uri'

module RSolr::HTTPClient
  
  autoload :Adapter, 'rsolr/http_client/adapter'
  
  class UnkownAdapterError < RuntimeError; end
  
  class Connector
    
    attr_accessor :adapter_name
    
    def initialize(adapter_name = :curb)
      @adapter_name = adapter_name
    end
    
    def connect(url)
      case adapter_name
      when :curb
        klass = 'Curb'
      when :net_http
        klass = 'NetHTTP'
      else
        raise UnkownAdapterError.new("Name: #{adapter_name}")
      end
      begin
        RSolr::HTTPClient::Base.new RSolr::HTTPClient::Adapter.const_get(klass).new(url)
      rescue ::URI::InvalidURIError
        raise "#{$!} == #{url}"
      end
    end
    
  end
  
  class Base
    
    attr_reader :adapter
    
    def initialize(adapter)
      @adapter = adapter
    end
    
    def get(path, params={})
      begin
        http_context = @adapter.get(path, params)
      rescue
        raise RSolr::RequestError.new($!)
      end
      http_context
    end
    
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

    def build_url(url='', params={}, string_query='')
      queries = [string_query, hash_to_params(params)]
      queries.delete_if{|i| i.to_s.empty?}
      url += "?#{queries.join('&')}" unless queries.empty?
      url
    end

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
      params = params.inject({}){|acc,(k,v)| acc.merge({k.to_s, v}) }
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