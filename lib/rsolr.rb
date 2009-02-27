# add this directory to the load path if it hasn't already been added
# load xout and rfuzz libs
proc {|base, files|
  $: << base unless $:.include?(base) || $:.include?(File.expand_path(base))
  files.each {|f| require f}
}.call(File.dirname(__FILE__), ['core_ext', 'mash'])

module RSolr
  
  VERSION = '0.7.0'
  
  autoload :Message, 'rsolr/message'
  autoload :Response, 'rsolr/response'
  autoload :Connection, 'rsolr/connection'
  autoload :Indexer, 'rsolr/indexer'
  autoload :HTTPClient, 'rsolr/http_client'
  
  # factory for creating connections
  # opts[:adapter] is either :http or :direct
  # opts are sent to the adapter instance (:url for http, :dist_dir for :direct etc.)
  # and to the connection instance
  def self.connect(opts={})
    adapter_name = opts[:adapter] ||= :http
    types = {
      :http=>'HTTP',
      :direct=>'Direct'
    }
    opts[:select_path] ||= 'select'
    opts[:update_path] ||= 'update'
    opts[:luke_path] ||= 'admin/luke'
    adapter_class = RSolr::Connection::Adapter.const_get(types[adapter_name])
    RSolr::Connection::Base.new(adapter_class.new(opts), opts)
  end
  
  class RequestError < RuntimeError; end
  
end