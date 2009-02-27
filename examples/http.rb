# Must be executed using jruby
require File.join(File.dirname(__FILE__), '..', 'lib', 'rsolr')

solr = RSolr.connect

`cd ../apache-solr/example/exampledocs && ./post.sh ./*.xml`

response = solr.query :q=>'ipod', :fq=>'price:[0 TO 50]', :rows=>2, :start=>0

solr.delete_by_query('*:*')

response.docs.each do |doc|
  if doc.has?(:timestamp)
    puts doc[:timestamp]
  end
end