
require 'rubygems'
$: << File.dirname(__FILE__) unless $:.include?(File.dirname(__FILE__))

module RSolr
  
  VERSION = '0.11.2'
  
  autoload :Message, 'rsolr/message'
  autoload :Client, 'rsolr/client'
  autoload :Connection, 'rsolr/connection'
  autoload :Adaptable, 'rsolr/adaptable'
  
  extend Adaptable
  
  # default is net_http
  self.default_adapter = :net_http
  
  # factory for direct connection.
  # if a block is given when calling connect,
  # yield the direct connection, close and return nil
  # else return the connection and assume the
  # client code will close the conenction.
  self.adapters[:direct] = lambda{|opts,&blk|
    opts ||= {}
    c = Connection::Adapters::Direct.new(opts)
    if blk
      blk.call c
      c.close
      return
    end
  }
  
  # factory for net_http
  self.adapters[:net_http] = lambda{|opts,&blk|
    opts ||= {}
    Connection::Adapters::NetHttp.new opts
  }
  
  # factory for curb
  self.adapters[:curb] = lambda{|opts,&blk|
    opts ||= {}
    Connection::Adapters::Curb.new opts
  }
  
  # Http connection. Example:
  #   RSolr.connect
  #   RSolr.connect 'http://solr.web100.org'
  #   RSolr.connect :direct, :solr_home => ''
  #   RSolr.connect :async
  def self.connect *args, &blk
    Client.new self.adapter(*args, &blk)
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