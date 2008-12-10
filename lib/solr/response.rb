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