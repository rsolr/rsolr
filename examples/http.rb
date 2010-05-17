require File.join(File.dirname(__FILE__), '..', 'lib', 'rsolr')

solr = RSolr.connect

# r = solr.request "/admin/cores", :action => "STATUS"
# puts r.inspect

# Dir['../solr/example/exampledocs/*.xml'].each do |xml_file|
#   puts "Updating with #{xml_file}"
#   r = solr.update File.read(xml_file)
#   puts 'ok!'
# end
# 
# solr.commit

puts

response = solr.select(:q=>'ipod', :fq=>['price:[0 TO 50]'], :rows=>2, :start=>0)

puts "URL : #{response.context[:request][:uri].to_s(true)}"

puts "STATUS : #{response.context[:response][:status_code]}"

puts

response['response']['docs'].each do |doc|
  puts doc['name']
end

# solr.delete_by_query('*:*') and solr.commit