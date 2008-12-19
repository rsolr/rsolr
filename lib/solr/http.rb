require 'uri'

# A simple wrapper for different http client implementations
# that supports #get and #post
# This was motivated by: http://apocryph.org/2008/11/09/more_indepth_analysis_ruby_http_client_performance/
# Curb/curl is the default adapter

module Solr::HTTP
  
  autoload :Adapter, 'solr/http/adapter'
  
  class UnkownAdapterError < RuntimeError; end
  
  def self.connect(url, adapter_name=:net_http)
    case adapter_name
    when :curb
      klass = 'Curb'
    when :net_http
      klass = 'NetHTTP'
    else
      raise UnkownAdapterError.new("Name: #{adapter_name}")
    end
    a = Kernel.eval("Solr::HTTP::Adapter::#{klass}").new(url)
    Base.new(a)
  end
  
  class Base
    
    attr_reader :adapter
    
    def initialize(adapter)
      @adapter = adapter
    end
    
    def get(path, params={})
      begin
        @adapter.get(path, params)
      rescue
        raise Solr::RequestError.new($!)
      end
    end
    
    def post(path, data, params={}, headers={})
      begin
        @adapter.post(path, data, params, headers)
      rescue
        raise Solr::RequestError.new($!)
      end
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
  
end