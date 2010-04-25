require 'rubygems'

$:.unshift File.dirname(__FILE__) unless $:.include?(File.dirname(__FILE__))

module RSolr
  
  module Contextable
    attr_reader :context
    def initialize c
      self.context = c
    end
    def context= c
      raise "Can't set RSolr context, already set." if @context
      @context = c
    end
  end
  
  def self.version
    @version ||= File.read(File.join(File.dirname(__FILE__), '..', 'VERSION'))
  end
  
  VERSION = self.version
  
  autoload :Message, 'rsolr/message'
  autoload :Client, 'rsolr/client'
  autoload :Connection, 'rsolr/connection'
  autoload :Uri, 'rsolr/uri'
  
  module Connectable
    
    def connect opts={}
      Client.new Connection::NetHttp.new(opts)
    end
    
  end
  
  extend Connectable
  
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
  class RequestError < RuntimeError
    include Contextable
    def to_s
      "#{URI.decode(context[:request][:uri].to_s)} - #{context[:response][:status_code]}"
    end
  end
  
end