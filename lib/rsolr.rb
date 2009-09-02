# add this directory to the load path if it hasn't already been added

$: << File.dirname(__FILE__) unless $:.include?(File.dirname(__FILE__))

module RSolr
  
  VERSION = '0.9.5'
  
  autoload :Message, 'rsolr/message'
  autoload :Connection, 'rsolr/connection'
  autoload :HTTPClient, 'rsolr/http_client'
  
  # Factory for creating connections.
  # Can specify the connection type by
  # using :http or :direct for the first argument.
  # The last argument is always used for the connection
  # adapter instance.
  # Examples:
  # # default http connection
  # RSolr.connect
  # # http connection with custom url
  # RSolr.connect :url=>'http://solr.web100.org'
  # # direct connection
  # RSolr.connect :direct, :home_dir=>'solr', :dist_dir=>'solr-nightly'
  def self.connect(*args)
    type = :http
    opts = {}
    if args.size==2
      type = args.first
      opts = args.slice(1..-1)
    end
    type_class = case type
      when :http
        'HTTP'
      when :direct
        'Direct'
      else
        raise "Invalid connection type: #{type} - use :http, :direct or leave nil for :http/default"
      end
    adapter_class = RSolr::Connection.const_get type_class
    adapter = adapter_class.new opts
    RSolr::Connection.new adapter
  end
  
  # A module that contains string related methods
  module Char
    
    # escape - from the solr-ruby library
    # RSolr.escape('asdf')
    # backslash everything that isn't a word character
    def escape(value)
      value.gsub(/(\W)/, '\\\\\1')
    end
    
  end
  
  # send the escape method into the Connection class ->
  # solr = RSolr.connect
  # solr.escape('asdf')
  RSolr::Connection.send(:include, Char)
  
  # bring escape into this module (RSolr) -> RSolr.escape('asdf')
  extend Char
  
  # RequestError is a common/generic exception class used by the adapters
  class RequestError < RuntimeError; end
  
end