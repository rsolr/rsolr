require 'uri'
require 'net/http'
require 'net/https'
require 'rubygems'
require 'builder'

$: << "#{File.dirname(__FILE__)}"

module RSolr
  
  %W(Char Client Error Http Response Uri Xml).each{|n|autoload n.to_sym, "rsolr/#{n.downcase}"}
  
  def self.version
    @version ||= File.read(File.join(File.dirname(__FILE__), '..', 'VERSION')).chomp
  end
  
  VERSION = self.version
  
  def self.connect *args
    opts = parse_options *args
    Client.new Http.new(opts[0], opts[1])
  end
  
  def self.parse_options *args
    opts = args[-1].kind_of?(Hash) ? args.pop : {}
    url = args.empty? ? 'http://127.0.0.1:8983/solr/' : args[0]
    uri = Uri.create url
    proxy = Uri.create opts[:proxy] if opts[:proxy]
    [uri, {:proxy => proxy}]
  end
  
  # RSolr.escape
  extend Char
  
end