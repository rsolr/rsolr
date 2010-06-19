namespace :rsolr do
  
  desc "Starts the HTTP server used for running HTTP connection tests"
  task :start_test_server do
    system "cd solr/example; java -jar start.jar"
  end
  
end