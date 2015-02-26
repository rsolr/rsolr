module RSolr
  
  Dir.glob(File.expand_path("../rsolr/*.rb", __FILE__)).each{|rb_file| require(rb_file)}
  
  def self.connect *args
    driver = Class === args[0] ? args[0] : RSolr::Connection
    opts = Hash === args[-1] ? args[-1] : {}
    Client.new driver.new, opts
  end
  
  # RSolr.escape, which is deprecated as of 2015-02
  extend Char
  
  # backslash escape characters that have special meaning to Solr query parser
  # per http://lucene.apache.org/core/4_0_0/queryparser/org/apache/lucene/queryparser/classic/package-summary.html#Escaping_Special_Characters
  #  + - & | ! ( ) { } [ ] ^ " ~ * ? : \ /
  # see also http://svn.apache.org/repos/asf/lucene/dev/tags/lucene_solr_4_9_1/solr/solrj/src/java/org/apache/solr/client/solrj/util/ClientUtils.java
  #   escapeQueryChars method
  # @return [String] str with special chars preceded by a backslash
  def self.solr_escape(str)
    # note that the gsub will parse the escaped backslashes, as will the ruby code sending the query to Solr 
    # so the result sent to Solr is ultimately a single backslash in front of the particular character 
    str.gsub(/([+\-&|!\(\)\{\}\[\]\^"~\*\?:\\\/])/, '\\\\\1')
  end
  
end