require File.join(File.dirname(__FILE__), '..', 'lib', 'rsolr')

# wanna find out of runcoderun will give me nokogiri...
require "nokogiri"
#Nokogiri::XML("<test/>")

# returns true/false depending on whether or not JRuby is running
def jruby?; defined?(JRUBY_VERSION) end

# returns absolute path to solr distribution dir
def solr_dist_dir
  File.expand_path(File.join(File.dirname(__FILE__), '..', 'solr'))
end

# returns absolute path to solr home dir
def solr_home_dir
  File.expand_path(File.join(solr_dist_dir, 'example', 'solr'))
end

# returns absolute path to solr data dir
def solr_data_dir
  File.expand_path(File.join(solr_dist_dir, 'example', 'solr', 'data'))
end

if jruby?
  ['lib', 'dist'].each do |sub|
    Dir[File.join(solr_dist_dir, sub, '*.jar')].each do |jar|
      require jar
    end
  end
end

# creates a new SolrCore
def new_solr_core solr_home_path, solr_data_path
  
  import org.apache.solr.core.SolrResourceLoader
  import org.apache.solr.core.CoreContainer
  import org.apache.solr.core.SolrConfig
  import org.apache.solr.core.CoreDescriptor
  import org.apache.solr.schema.IndexSchema
  import org.apache.solr.core.SolrCore
  
  config_file = SolrConfig::DEFAULT_CONF_FILE
  
  resource_loader = SolrResourceLoader.new(solr_home_path)
  cores = CoreContainer.new(resource_loader)
  
  solr_config = SolrConfig.new(solr_home_path, config_file, nil)
  
  dcore = CoreDescriptor.new(cores, "", solr_config.getResourceLoader().getInstanceDir())
  
  index_schema = IndexSchema.new(solr_config, "#{solr_home_dir}/conf/schema.xml", nil)
  
  core = SolrCore.new( nil, solr_data_path, solr_config, index_schema, dcore)
  
  cores.register("", core, false)
  
  core
end