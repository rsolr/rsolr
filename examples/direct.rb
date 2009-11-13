# Must be executed using jruby
require File.join(File.dirname(__FILE__), '..', 'lib', 'rsolr')

base = File.expand_path( File.dirname(__FILE__) )
solr_base = File.join(base, '..', 'solr')
home = File.join(solr_base, 'example', 'solr')

RSolr.direct_connect(:home_dir=>home) do |solr|

  Dir['../apache-solr/example/exampledocs/*.xml'].each do |xml_file|
    puts "Updating with #{xml_file}"
    solr.update File.read(xml_file)
  end
  
  solr.commit
  
  puts
  
  response = solr.select :q=>'ipod', :fq=>'price:[0 TO 50]', :rows=>2, :start=>0
  
  docs = response['response']['docs']
  
  docs.each do |doc|
    puts doc['timestamp']
  end
  
  solr.delete_by_query('*:*') and solr.commit
  
end