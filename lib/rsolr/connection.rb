module RSolr::Connection
  
  autoload :Direct, 'rsolr/connection/direct'
  autoload :NetHttp, 'rsolr/connection/net_http'
  autoload :Curb, 'rsolr/connection/curb'
  
  autoload :Utils, 'rsolr/connection/utils'
  autoload :Httpable, 'rsolr/connection/httpable'
  
end