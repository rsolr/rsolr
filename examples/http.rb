require File.join(File.dirname(__FILE__), '..', 'lib', 'rsolr')

solr = RSolr.connect

response = solr.select(:q => 'asd')

puts response.raw.inspect

exit

# r = solr.request "/admin/cores", :action => "STATUS"
# puts r.inspect

Dir['../solr/example/exampledocs/*.xml'].each do |xml_file|
  puts "Updating with #{xml_file}"
  solr.update File.read(xml_file)
  puts 'ok!'
end

solr.commit

puts

response = solr.select(:q=>'ipod', :fq=>['price:[0 TO 50]'], :rows=>2, :start=>0)

puts "URL : #{response.raw[:url]} -> #{response.raw[:status_code]}"

puts

response['response']['docs'].each do |doc|
  puts doc['timestamp']
end

solr.delete_by_query('*:*') and solr.commit