require 'uri'
require 'net/http'
require 'net/https'
require 'rubygems'
require 'builder'

$: << "#{File.dirname(__FILE__)}"

module RSolr
  
  %W(Http Uri Client Xml Char).each{|n|autoload n.to_sym, "rsolr/#{n.downcase}"}
  
  def self.connect *args
    opts = parse_options *args
    Client.new Http.new(opts[0], opts[1])
  end
  
  def self.parse_options *args
    opts = args[-1].kind_of?(Hash) ? args.pop : {}
    url = args.empty? ? 'http://127.0.0.1:8983/solr/' : args[0]
    url << "#{opts.delete :core}/" if opts[:core]
    proxy = opts[:proxy] ? URI.parse(opts[:proxy]) : nil
    uri = URI.parse url
    [uri, {:proxy => proxy}]
  end
  
end