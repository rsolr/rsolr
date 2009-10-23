raise "JRuby Required" unless defined?(JRUBY_VERSION)

require 'java'

#
# Connection for JRuby + DirectSolrConnection
#
class RSolr::Connection::Direct
  
  include RSolr::Connection::Utils
  
  attr_accessor :opts
  
  # opts can be an instance of org.apache.solr.servlet.DirectSolrConnection
  # if opts is NOT an instance of org.apache.solr.servlet.DirectSolrConnection
  # then...
  # required: opts[:home_dir] is absolute path to solr home (the directory with "data", "config" etc.)
  # opts must also contain either
  #   :dist_dir => 'absolute path to solr distribution root
  # or
  #   :jar_paths => ['array of directories containing the solr lib/jars']
  # OTHER OPTS:
  #   :select_path => 'the/select/handler'
  #   :update_path => 'the/update/handler'
  def initialize(opts, &block)
    if defined?(Java::OrgApacheSolrCore::SolrCore) and opts.is_a?(Java::OrgApacheSolrCore::SolrCore)
      @connection = org.apache.solr.servlet.DirectSolrConnection.new(opts)
    elsif defined?(Java::OrgApacheSolrServlet::DirectSolrConnection) and opts.is_a?(Java::OrgApacheSolrServlet::DirectSolrConnection)
      @connection = opts
    else
      opts[:data_dir] ||= File.join(opts[:home_dir].to_s, 'data')
      if opts[:dist_dir] and ! opts[:jar_paths]
        # add the standard lib and dist directories to the :jar_paths
        opts[:jar_paths] = [File.join(opts[:dist_dir], 'lib'), File.join(opts[:dist_dir], 'dist')]
      end
      @opts = opts
    end
  end
  
  # loads/imports the java dependencies
  # sets the @connection instance variable if it has not yet been set
  def connection
    @connection ||= (
      require_jars(@opts[:jar_paths]) if @opts[:jar_paths]
      org.apache.solr.servlet.DirectSolrConnection.new(opts[:home_dir], @opts[:data_dir], nil)
    )
  end
  
  def close
    if @connection
      @connection.close
      @connection=nil
    end
  end
  
  # send a request to the connection
  # request '/select', :q=>'something'
  # request '/update', :wt=>:xml, '</commit>'
  def request(path, params={}, data=nil, opts={})
    data = data.to_xml if data.respond_to?(:to_xml)
    url = build_url(path, params)
    begin
      body = connection.request(url, data)
    rescue
      raise RSolr::RequestError.new($!.message)
    end
    {
      :body=>body,
      :url=>url,
      :path=>path,
      :params=>params,
      :data=>data,
    }
  end
  
  protected
  
  # require the jar files
  def require_jars(paths)
    paths = [paths] unless paths.is_a?(Array)
    paths.each do |path|
      raise "Invalid jar path: #{path}" unless File.exists?(path)
      jar_pattern = File.join(path,"**", "*.jar")
      Dir[jar_pattern].each {|jar_file| require jar_file }
    end
  end
  
end