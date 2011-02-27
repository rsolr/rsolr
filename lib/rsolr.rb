$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'bundler'
Bundler.require

require 'rsolr/char'

module RSolr
  extend Char

  autoload :Client,     'rsolr/client'
  autoload :Error,      'rsolr/error'
  autoload :Connection, 'rsolr/connection'
  autoload :Pagination, 'rsolr/pagination'
  autoload :Uri,        'rsolr/uri'
  autoload :Xml,        'rsolr/xml'

  # Convenience method
  #   @see RSolr::Client#new
  def self.connect *args
    Client.new *args
  end
end
