# Must be executed using jruby
require File.join(File.dirname(__FILE__), '..', 'lib', 'rsolr')

solr = RSolr.connect

`cd ../apache-solr/example/exampledocs && ./post.sh ./*.xml`

response = solr.search :q=>'ipod', :fq=>'price:[0 TO 50]', :per_page=>2, :page=>1

solr.delete_by_query('*:*')

response.docs.each do |doc|
  if doc.has?(:timestamp)
    puts doc[:timestamp]
  end
end