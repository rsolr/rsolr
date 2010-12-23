require "#{File.dirname(__FILE__)}/lib/rsolr"
require 'rubygems'
require 'builder'

# puts RSolr::Uri.params_to_solr({:id => "test this - or this, '; ", :fq => [1, 2, 3]}, false)
# puts RSolr.escape("OR this and +that but NOT this")

solr = RSolr.connect :url => "http://localhost:8983/solr"

r = solr.paginate 23, 10, "select", :params => {:q => "*:*"}

puts r["response"]["docs"].inspect

begin
  r = solr.get 'select', :params => {:q => '*:*', :wt => :ruby}
rescue
  puts $!
  puts $!.backtrace
  exit
end

puts r["response"]["docs"].inspect

r = solr.build_request "select", :params => {:q => "hello", :fq => ["one:1", "two:2"]}, :method => :post
puts r[:uri]

begin
  r = solr.select :params => {"q" => "*:*", "facet" => true, "facet.field" => "cat"}
  r["facet_counts"]["facet_fields"].each_pair do |field, hits|
    hits.each_slice 2 do |k,v|
      puts "#{k} : #{v}"
    end
    puts
  end
rescue
  raise $!
end

begin
  r = solr.select :params => {:q => '*:*!', :fw => ["one", "two"]}
rescue
  puts $!
  puts $!.backtrace.join("\n")
end

puts

r = solr.build_request 'select', :params => {:q => '*:*', :fw => ["one", "two"]}
puts r[:uri].inspect

puts

response = solr.get "select", :params => {:q => "*:*"}
puts response["response"]["docs"].size

r = solr.select(
  :params => {:q => '*:*'},
  :headers => {"Cache-Control" => "max-age=0, no-cache, no-store, must-revalidate"}
)

puts "basic select using RSolr::Client #method_missing"
puts r.inspect
puts

# "blah/blah/blah" doesn't exists, so a http error is raised...
begin
  solr.head "blah/blah/blah"
rescue
  puts $!.request.inspect
  puts "====================="
  # the error will have #request and #response attributes
  # puts "blah blah blah HEAD response: " + $!.response.inspect
end

puts

# "admin" exists so we can check the return value's original response status code
#puts "admin HEAD response: " + solr.head("admin").inspect
#puts

# add some shiz via solr.xml
add_xml = solr.xml.add({:name_s => "blah blah", :id => Time.now.to_s}, :add_attributes => {:boost=>5.0, :commitWithin=>1}) do |xml|
  # can setup individual doc add attributes here...
end

solr.update :data => add_xml
solr.commit
solr.optimize

begin
  result = solr.get 'select', :params => {:q => '*:*'}
  puts "response['docs']:"
  result['response']['docs'].each do |doc|
    puts doc.inspect
  end
rescue
  puts $!.to_s
end

puts

# puts "Deleting all!"
# solr.delete_by_query "*:*"
# solr.commit