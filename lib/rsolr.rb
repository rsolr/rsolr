require 'rubygems'

$:.unshift File.dirname(__FILE__) unless $:.include?(File.dirname(__FILE__))

module RSolr
  
  def self.connect opts={}
    Client.new Adapter::NetHttp.new(opts)
  end
  
  def self.version
    @version ||= File.read(File.join(File.dirname(__FILE__), '..', 'VERSION'))
  end
  
  VERSION = self.version
  
  autoload :Message, 'rsolr/message'
  autoload :Client, 'rsolr/client'
  autoload :Connectable, 'rsolr/connectable'
  autoload :Adapter, 'rsolr/adapter'
  autoload :Uri, 'rsolr/uri'
  
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
  
  # A module that contains string related methods
  module Char
    
    # escape - from the solr-ruby library
    # RSolr.escape('asdf')
    # backslash everything that isn't a word character
    def escape(value)
      value.gsub(/(\W)/, '\\\\\1')
    end
    
  end
  
  # bring escape into this module (RSolr) -> RSolr.escape('asdf')
  extend Char
  
  # RequestError is a common/generic exception class used by the adapters
  class RequestError < RuntimeError
    include Contextable
    def to_s
      "#{context[:response][:status_code]} - #{URI.decode(context[:request][:uri].to_s)}"
    end
  end
  
end