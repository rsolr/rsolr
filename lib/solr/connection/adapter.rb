module Solr::Connection::Adapter
  
  autoload :Direct, 'solr/connection/adapter/direct'
  autoload :HTTP, 'solr/connection/adapter/http'
  autoload :CommonMethods, 'solr/connection/adapter/common_methods'
  
end