# add this directory to the load path if it hasn't already been added

require 'rubygems'

$: << File.dirname(__FILE__) unless $:.include?(File.dirname(__FILE__))

require 'xout'

module RSolr
  
  VERSION = '0.9.7.2'
  
  autoload :Message, 'rsolr/message'
  autoload :Client, 'rsolr/client'
  autoload :Connection, 'rsolr/connection'
  
  # Factory for creating connections.
  # 2 modes of argument operations:
  #   1. first argument is solr-adapter type, second arg is options hash for solr-adapter instance.
  #   2. options hash for solr-adapter only (no adapter type as first arg)
  #
  # Examples:
  # # default http connection
  # RSolr.connect
  # # http connection with custom url
  # RSolr.connect :url=>'http://solr.web100.org'
  # # direct connection
  # RSolr.connect :direct, :home_dir=>'solr', :dist_dir=>'solr-nightly'
  def self.connect(*args)
    type = args.first.is_a?(Symbol) ? args.shift : :http
    opts = args
    type_class = case type
      when :net_http,:http,nil
        'NetHttp'
      when :direct
        'Direct'
      else
        raise "Invalid connection type: #{type} - use :http, :direct or leave nil for :http/default"
      end
    adapter_class = RSolr::Connection.const_get(type_class)
    adapter = adapter_class.new(*opts)
    RSolr::Client.new(adapter)
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
  RSolr::Client.send(:include, Char)
  
  # bring escape into this module (RSolr) -> RSolr.escape('asdf')
  extend Char
  
  # RequestError is a common/generic exception class used by the adapters
  class RequestError < RuntimeError; end
  
end