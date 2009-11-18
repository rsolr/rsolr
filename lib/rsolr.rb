# add this directory to the load path if it hasn't already been added

require 'rubygems'

$: << File.dirname(__FILE__) unless $:.include?(File.dirname(__FILE__))

require 'xout'

module RSolr
  
  VERSION = '0.11.1'
  
  autoload :Message, 'rsolr/message'
  autoload :Client, 'rsolr/client'
  autoload :Connection, 'rsolr/connection'
  
  # Http connection. Example:
  #   RSolr.connect
  #   RSolr.connect 'http://solr.web100.org'
  def self.connect *args
    Client.new(Connection::NetHttp.new(*args))
  end
  
  # DirectSolrConnection (jruby only). Example:
  #   RSolr.direct_connect 'path/to/solr/distribution'
  #   RSolr.direct_connect :dist_dir=>'path/to/solr/distribution', :home_dir=>'/path/to/solrhome'
  #   RSolr.direct_connect opts do |rsolr|
  #     ###
  #   end
  # Note:
  # if a block is used, the client is yielded and the solr core will be closed for you.
  # if a block is NOT used, the the client is returned and the core is NOT closed.
  def self.direct_connect *args, &blk
    rsolr = Client.new(Connection::Direct.new(*args))
    block_given? ? (yield rsolr and rsolr.connection.close) : rsolr
  end
  
  # A module that contains string related methods
  module Char
    
    # escape - from the solr-ruby library
    # RSolr.escape('asdf')
    # backslash everything that isn't a word character
    def escape(value)
      value.gsub(/(\W)/, '\\\\\1')
    end
    
  end
  
  # send the escape method into the Connection class ->
  # solr = RSolr.connect
  # solr.escape('asdf')
  RSolr::Client.send(:include, Char)
  
  # bring escape into this module (RSolr) -> RSolr.escape('asdf')
  extend Char
  
  # RequestError is a common/generic exception class used by the adapters
  class RequestError < RuntimeError; end
  
end