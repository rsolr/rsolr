module Solr::Response
  
  # default/base response object
  class Base
    
    attr_reader :raw_response, :data, :header, :params, :status, :query_time
    
    def initialize(data)
      if data.is_a?(String)
        @raw_response = data
        @data = Kernel.eval(@raw_response)
      else
        @data = data
      end
      @header = @data['responseHeader']
      @params = @header['params']
      @status = @header['status']
      @query_time = @header['QTime']
    end
    
    def ok?
      self.status==0
    end
    
  end
  
=begin
  class Document
    
    attr_reader :data
    
    def initialize(source_hash)
      source_hash.each do |k,v|
        @data[k.to_sym]=v
        instance_eval <<-EOF
          def #{k}
            @data[:#{k}]
          end
        EOF
      end
    end
    
    #
    # doc.has?(:location_facet, 'Clemons')
    # doc.has?(:id, 'h009', /^u/i)
    #
    def has?(k, *values)
      return if @data[k].nil?
      target = @data[k]
      if target.is_a?(Array)
        values.each do |val|
          return target.any?{|tv| val.is_a?(Regexp) ? (tv =~ val) : (tv==val)}
        end
      else
        return values.any? {|val| val.is_a?(Regexp) ? (target =~ val) : (target == val)}
      end
    end

    #
    def get(key, default=nil)
      @data[key] || default
    end
    
  end
=end
  
  # response for queries
  class Query < Base
    
    attr_reader :response, :docs, :num_found, :start
    
    alias :total :num_found
    alias :offset :start
    
    def initialize(data)
      super(data)
      @response = @data['response']
      @docs = @response['docs']
      @num_found = @response['numFound']
      @start = @response['start']
    end
    
  end
  
  # response class for update requests
  class Update < Base
    
  end
  
  # response for /admin/luke
  class IndexInfo < Base
    
    attr_reader :index, :directory, :has_deletions, :optimized, :current, :max_doc, :num_docs, :version
    
    alias :has_deletions? :has_deletions
    alias :optimized? :optimized
    alias :current? :current
    
    def initialize(data)
      super(data)
      @index = @data['index']
      @directory = @data['directory']
      @has_deletions = @index['hasDeletions']
      @optimized = @index['optimized']
      @current = @index['current']
      @max_doc = @index['maxDoc']
      @num_docs = @index['numDocs']
      @version = @index['version']
    end
    
  end
  
end