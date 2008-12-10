module Solr::Connection::Adapter
  
  class RequestError < RuntimeError; end
  
  autoload :Direct, 'solr/connection/adapter/direct'
  autoload :HTTP, 'solr/connection/adapter/http'
  autoload :Helpers, 'solr/connection/adapter/helpers'
  
  #autoload :Embedded, 'solr/adapter/embedded'
  #autoload :HTTPCommons, 'solr/adapter/http_commons'
  
  # LukeRequest luke = new LukeRequest();
  # luke.setShowSchema( false );
  # LukeResponse rsp = luke.process( server );
  
end