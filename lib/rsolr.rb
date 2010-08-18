$: << "#{File.dirname(__FILE__)}" unless $:.include? File.dirname(__FILE__)

require 'rubygems'

module RSolr
  
  %W(Char Client Connectable Error Http Uri Xml).each{|n|autoload n.to_sym, "rsolr/#{n.downcase}"}
  
  def self.version
    @version ||= File.read(File.join(File.dirname(__FILE__), '..', 'VERSION')).chomp
  end
  
  VERSION = self.version
  
  def self.connect *args
    Client.new Http.new(*args)
  end
  
  # RSolr.escape
  extend Char
  
end