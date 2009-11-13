namespace :rsolr do
  
  desc "Starts the HTTP server used for running HTTP connection tests"
  task :start_test_server do
    system "cd solr/example; java -jar start.jar"
  end
  
  desc 'copy the solr java dependencies to ./java/'
  task :copy_java do
    deps = %W(
    solr/lib/slf4j-api-1.5.5.jar
    solr/lib/slf4j-jdk14-1.5.5.jar
    solr/lib/commons-fileupload-1.2.1.jar
    solr/lib/servlet-api-2.4.jar
    solr/lib/commons-io-1.4.jar
    solr/lib/lucene-analyzers-2.9-dev.jar
    solr/lib/lucene-core-2.9-dev.jar
    solr/lib/lucene-highlighter-2.9-dev.jar
    solr/lib/lucene-memory-2.9-dev.jar
    solr/lib/lucene-misc-2.9-dev.jar
    solr/lib/lucene-queries-2.9-dev.jar
    solr/lib/lucene-snowball-2.9-dev.jar
    solr/lib/lucene-spellchecker-2.9-dev.jar
    solr/dist/apache-solr-core-nightly.jar
    solr/dist/apache-solr-solrj-nightly.jar
    )
    deps.each do |dep|
      puts "copying #{dep}"
      FileUtils.cp dep, 'java/'
    end
  end
  
end