require 'lib/rsolr'

solr = RSolr.connect "http://localhost:9999/solr/"

r = solr.select(
  :params => {:q => '*:*'},
  :headers => {"Cache-Control" => "max-age=0, no-cache, no-store, must-revalidate"}
)

puts "basic select using RSolr::Client #method_missing"
puts r.inspect
puts

# "asdf" doesn't exists, so a http error is raised...
begin
  solr.head "blah blah blah"
rescue
  puts $!
  # the error will have #request and #response attributes
  puts "blah blah blah HEAD response: " + $!.response.inspect
end

puts

# "admin" exists so we can check the return value's original response status code
puts "admin HEAD response: " + solr.head("admin/").response.inspect
puts

# add some shiz
add_response = solr.add({:name_s => "blah blah", :id => Time.now.to_s}, :xml_add_attrs => {:boost=>5.0, :commitWithin=>1})
puts add_response.request[:data]
solr.commit
solr.optimize

begin
  result = solr.get 'select', :params => {:q => '*:*'}
  puts "Data sent to Solr:"
  puts result.request.inspect
  puts
  puts "Data returned from Solr:"
  puts result.response.inspect
  puts
  puts "response['docs']:"
  result['response']['docs'].each do |doc|
    puts doc.inspect
  end
rescue
  puts $!.to_s
end

solr.delete_by_query "*:*"
solr.commit