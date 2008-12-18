# add this directory to the load path if it hasn't already been added
# load xout and rfuzz libs
proc {|base, files|
  $: << base unless $:.include?(base) || $:.include?(File.expand_path(base))
  files.each {|f| require f}
}.call(File.dirname(__FILE__), ['core_ext'])

module Solr
  
  VERSION = '0.5.3'
  
  autoload :Adapter, 'solr/adapter'
  autoload :Message, 'solr/message'
  autoload :Response, 'solr/response'
  autoload :Connection, 'solr/connection'
  autoload :Ext, 'solr/ext'
  autoload :Mapper, 'solr/mapper'
  autoload :Indexer, 'solr/indexer'
  
  # factory for creating connections
  # adapter name is either :http or :direct
  # opts are sent to the adapter instance (:url for http, :dist_dir for :direct etc.)
  # and to the connection instance
  def self.connect(adapter_name, opts={})
    types = {
      :http=>'HTTP',
      :direct=>'Direct'
    }
    adapter_class_name = "Solr::Adapter::#{types[adapter_name]}"
    adapter_class = Kernel.eval adapter_class_name
    Solr::Connection::Base.new(adapter_class.new(opts), opts)
  end
  
  class RequestError < RuntimeError; end
  
end