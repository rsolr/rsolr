namespace :rsolr do
  
  namespace :solr do
    desc "Starts the HTTP server (port 9999) used for running HTTP connection tests"
    task :start do
      system "cd jetty; java -jar start.jar"
    end
  end
  
end