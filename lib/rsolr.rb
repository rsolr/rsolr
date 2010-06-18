require 'net/http'
require 'rubygems'
require 'builder'
require 'uri'
require 'net/http'
require 'net/https'

$: << "#{File.dirname(__FILE__)}"

module RSolr
  
  autoload :Http, 'rsolr/http'
  autoload :Uri, 'rsolr/uri'
  autoload :Client, 'rsolr/client'
  autoload :Xml, 'rsolr/xml'
  autoload :Char, 'rsolr/char'
  
  def self.parse_options *args
    opts = args[-1].kind_of?(Hash) ? args.pop : {}
    url = args.empty? ? 'http://127.0.0.1:8983/solr/' : args[0]
    url << "#{opts.delete :core}/" if opts[:core]
    proxy = opts[:proxy] ? URI.parse(opts[:proxy]) : nil
    uri = URI.parse url
    [uri, {:proxy => proxy}]
  end
  
  def self.connect *args
    opts = parse_options *args
    Client.new Http.new(opts[0], opts[1])
  end
  
end