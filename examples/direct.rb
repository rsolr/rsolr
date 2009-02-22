# Must be executed using jruby
require File.join(File.dirname(__FILE__), '..', 'lib', 'rsolr')

base = File.expand_path( File.dirname(__FILE__) )
dist = File.join(base, '..', 'apache-solr')
home = File.join(dist, 'example', 'solr')

solr = RSolr.connect(:adapter=>:direct, :home_dir=>home, :dist_dir=>dist)

`cd ../apache-solr/example/exampledocs && ./post.sh ./*.xml`

# the 'select' here is optional
response = solr.query 'select', :q=>'ipod', :fq=>'price:[0 TO 50]', :rows=>2, :start=>0

solr.delete_by_query('*:*')

response.docs.each do |doc|
  if doc.has?(:timestamp)
    puts doc[:timestamp]
  end
end