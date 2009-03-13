require File.join(File.dirname(__FILE__), '..', 'lib', 'rsolr')

solr = RSolr.connect

# switch out the http adapter from curb to net_http (just for an example)
solr.adapter.connector.adapter_name = :curb

Dir['../apache-solr/example/exampledocs/*.xml'].each do |xml_file|
  puts "Updating with #{xml_file}"
  solr.update File.read(xml_file)
end

puts

solr.select(:q=>'ipod', :fq=>'price:[0 TO 50]', :rows=>2, :start=>0) do |solr_response,adapter_response|
  puts "URL : #{adapter_response[:url]}"
  solr_response[:response][:docs].each do |doc|
    puts doc[:timestamp]
  end
end

solr.delete_by_query('*:*') and solr.commit