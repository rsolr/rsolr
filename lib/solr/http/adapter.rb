module Solr::HTTP::Adapter
  
  autoload :Curb, 'solr/http/adapter/curb'
  autoload :NetHTTP, 'solr/http/adapter/net_http'
  autoload :ApacheCommons, 'solr/http/adapter/apache_commons'
  
end