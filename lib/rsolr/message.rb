# The Solr::Message class is the XML generation module for sending updates to Solr.

module RSolr::Message
  
  autoload :Adapters, 'rsolr/message/adapters'
  autoload :Document, 'rsolr/message/document'
  autoload :Field, 'rsolr/message/field'
  autoload :Generator, 'rsolr/message/generator'
  
  extend RSolr::Adaptable
  
  self.default_adapter = :builder
  self.adapters[:builder] = lambda{RSolr::Message::Adapters::Builder.new}
  self.adapters[:nokogiri] = lambda{RSolr::Message::Adapters::Nokogiri.new}
  
  def self.create *args
    Generator.new self.adapter(*args)
  end
  
end