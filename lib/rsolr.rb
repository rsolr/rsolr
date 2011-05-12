$: << "#{File.dirname(__FILE__)}" unless $:.include? File.dirname(__FILE__)

require 'rubygems'

module RSolr
  
  %W(Char Client Error Connection Pagination Uri Xml).each{|n|autoload n.to_sym, "rsolr/#{n.downcase}"}
  
  def self.version
    @version ||= File.read(File.join(File.dirname(__FILE__), '..', 'VERSION')).chomp
  end
  
  VERSION = self.version
  
  def self.connect *args
    driver = args[0].is_a?(Class) ? args[0] : RSolr::Connection
    opts = args[-1].is_a?(Hash) ? args[-1] : {}
    Client.new driver.new, opts
  end
  
  # RSolr.escape
  extend Char
  
end