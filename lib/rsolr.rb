# add this directory to the load path if it hasn't already been added

if ! $:.include? File.dirname(__FILE__) or ! $:.include? File.expand_path(File.dirname(__FILE__))
  $: << File.dirname(__FILE__)
end

require 'core_ext'
require 'mash'

module RSolr
  
  VERSION = '0.8.3'
  
  autoload :Message, 'rsolr/message'
  autoload :Connection, 'rsolr/connection'
  autoload :Adapter, 'rsolr/adapter'
  autoload :HTTPClient, 'rsolr/http_client'
  
  # factory for creating connections
  # "options" is a hash that gets used by the Connection
  # object AND the adapter object.
  def self.connect(options={})
    adapter_name = options[:adapter] ||= :http
    types = {
      :http=>'HTTP',
      :direct=>'Direct'
    }
    adapter_class = RSolr::Adapter.const_get(types[adapter_name])
    adapter = adapter_class.new(options)
    RSolr::Connection.new(adapter, options)
  end
  
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
  
  class RequestError < RuntimeError; end
  
end