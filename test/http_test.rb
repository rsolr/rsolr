require File.join(File.dirname(__FILE__), 'test_helpers')

require 'connection_test_methods'

class HTTPTest < Test::Unit::TestCase
  
  include ConnectionTestMethods
  
  def setup
    @solr = Solr.connect(:http, {}, :auto_commit=>true)
  end
  
end