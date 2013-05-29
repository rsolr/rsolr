module RSolr
  
  Dir.glob(File.expand_path("../rsolr/*.rb", __FILE__)).each{|rb_file| require(rb_file)}
  
  def self.version; "1.0.9" end
  
  VERSION = self.version
  
  def self.connect *args
    driver = Class === args[0] ? args[0] : RSolr::Connection
    opts = Hash === args[-1] ? args[-1] : {}
    Client.new driver.new, opts
  end
  
  # RSolr.escape
  extend Char
  
end
