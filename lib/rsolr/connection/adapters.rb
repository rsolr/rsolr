module RSolr::Connection::Adapters
  
  autoload :Direct, 'rsolr/connection/adapters/direct'
  autoload :NetHttp, 'rsolr/connection/adapters/net_http'
  autoload :Curb, 'rsolr/connection/adapters/curb'
  
end