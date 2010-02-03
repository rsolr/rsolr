# The Solr::Message::Generator class is the XML generation module for sending updates to Solr.
module RSolr::Message
  
  autoload :Document, 'rsolr/message/document'
  autoload :Field, 'rsolr/message/field'
  autoload :Generator, 'rsolr/message/generator'
  
end