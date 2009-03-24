# add this directory to the load path if it hasn't already been added
# load xout and rfuzz libs
proc {|base, files|
  $: << base unless $:.include?(base) || $:.include?(File.expand_path(base))
  files.each {|f| require f}
}.call(File.dirname(__FILE__), ['core_ext', 'mash'])

module RSolr
  
  VERSION = '0.8.2'
  
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