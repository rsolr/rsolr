require 'java'
require 'rubygems'
require 'rsolr'

#
# Connection for JRuby + DirectSolrConnection
#
module RSolr::Direct
  
  # load the java libs that ship with rsolr-direct
  # RSolr.load_java_libs
  # rsolr = RSolr.connect :direct, :solr_home => ''
  def self.load_java_libs apache_solr_dir
    @java_libs_loaded ||= (
      base_dir = File.expand_path(apache_solr_dir)
      ['lib', 'dist'].each do |sub|
        Dir[File.join(base_dir, sub, '*.jar')].each do |jar|
          require jar
        end
      end
      true
    )
  end
  
  RSolr.class_eval do
    # RSolr.direct_connect :solr_home => 'apache-solr/example/solr'
    # RSolr.direct_connect java_solr_core
    # RSolr.direct_connect java_direct_solr_connection
    def self.direct_connect *args, &blk
      client = RSolr::Client.new RSolr::Direct::Connection.new(*args), {:url => false}
      if block_given?
        yield client
        client.connection.close
        nil
      else
        client
      end
    end
  end
  
  class Connection
    
    attr_accessor :opts
    
    class MissingRequiredJavaLibs < RuntimeError
    end
    
    class InvalidSolrHome < RuntimeError
    end
    
    # opts can be an instance of org.apache.solr.servlet.DirectSolrConnection
    # if opts is NOT an instance of org.apache.solr.servlet.DirectSolrConnection
    # then...
    # required: opts[:solr_home] is absolute path to solr home (the directory with "data", "config" etc.)
    def initialize opts
      begin
        org.apache.solr.servlet.DirectSolrConnection
      rescue NameError
        raise MissingRequiredJavaLibs
      end
      if opts.is_a?(Hash) and opts[:solr_home]
        raise InvalidSolrHome unless File.exists?(opts[:solr_home])
        opts[:data_dir] ||= File.join(opts[:solr_home], 'data')
        @opts = opts
      elsif opts.class.to_s == "Java::OrgApacheSolrCore::SolrCore"
        @direct = org.apache.solr.servlet.DirectSolrConnection.new(opts)
      elsif opts.class.to_s == "Java::OrgApacheSolrServlet::DirectSolrConnection"
        @direct = opts
      end
      opts[:auto_connect] = true unless opts.key?(:auto_connect)
      self.direct if opts[:auto_connect]
    end
    
    # sets the @direct instance variable if it has not yet been set
    def direct
      @direct ||= org.apache.solr.servlet.DirectSolrConnection.new(opts[:solr_home], @opts[:data_dir], nil)
    end
    
    # rsolr.connection.open
    alias_method :open, :direct
    
    def close
      if @direct
        @direct.close
        @direct = nil
      end
    end
    
    # send a request to the connection
    def execute client, request_context
      #data = request_context[:data]
      #data = data.to_xml if data.respond_to?(:to_xml)
      url = [request_context[:path], request_context[:query]].join("?")
      url = "/" + url unless url[0].chr == "/"
      begin
        body = direct.request(url, request_context[:data])
      rescue
        $!.extend RSolr::Error::SolrContext
        $!.request = request_context
        raise $!
      end
      {
        :status => 200,
        :body => body,
        :headers => {}
      }
    end
    
  end
  
end