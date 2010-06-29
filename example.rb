require 'lib/rsolr'

solr = RSolr.connect "http://localhost:9999/solr"

# "asdf" doesn't exists, so a http error is raised...
begin
  solr.head("asdf")
rescue
  # the error will have #request and #response attributes
  $!.response[:status] == 404
end

# "admin" exists so we can check the return value's original response status code
solr.head("admin").response[:status] == 200

# add some shiz
solr.add :name_s => "blah blah", :id => Time.now.to_s
solr.commit
solr.optimize

begin
  result = solr.get 'select', :q => '*:*'
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