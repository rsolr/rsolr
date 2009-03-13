# Must be executed using jruby
require File.join(File.dirname(__FILE__), '..', 'lib', 'rsolr')

base = File.expand_path( File.dirname(__FILE__) )
dist = File.join(base, '..', 'apache-solr')
home = File.join(dist, 'example', 'solr')

solr = RSolr.connect({:adapter=>:direct}, {:home_dir=>home, :dist_dir=>dist})

`cd ../apache-solr/example/exampledocs && ./post.sh ./*.xml`

response = solr.select :q=>'ipod', :fq=>'price:[0 TO 50]', :rows=>2, :start=>0

docs = response[:response][:docs]

docs.each do |doc|
  puts doc[:timestamp]
end

solr.delete_by_query('*:*') and solr.commit

solr.adapter.close