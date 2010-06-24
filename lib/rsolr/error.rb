module RSolr::Error
  
  module SolrContext
    
    attr_accessor :request_context, :response_context
    
    def to_s
      m = ""
      if response_context
        details = parse_solr_error_response response_context[:body]
        m << "Error: #{details}\n" if details
      end
      m << "\n#{super.to_s}:"
      m << "\n" + self.backtrace[0..10].join("\n")
      m << "\n\nSolr Request:"
      m << "\n  Method: #{request_context[:method].to_s.upcase}"
      m << "\n  Base URL: #{request_context[:connection].uri.to_s}"
      m << "\n  URL: #{request_context[:uri]}"
      m << "\n  Params: #{request_context[:params].inspect}"
      m << "\n  Data: #{request_context[:data].inspect}" if request_context[:data]
      m << "\n  Headers: #{request_context[:headers].inspect}"
      if response_context
        m << "\n\nSolr Response:"
        m << "\n  Code: #{response_context[:status]}"
        m << "\n  Headers: #{response_context[:headers].inspect}"
      end
      m
    end
    
    protected
    
    def parse_solr_error_response body
      begin
        info = body.scan(/<pre>(.*)<\/pre>/mi)[0]
        partial = info.to_s.split("\n")[0..10]
        partial.join("\n").gsub("&gt;", ">").gsub("&lt;", "<")
      rescue
        nil
      end
    end
    
  end
  
  class Http < RuntimeError
    
    include SolrContext
    
    def initialize request, response
      @request_context, @response_context = request, response
    end
    
  end
  
  # Thrown if the :wt is :ruby
  # but the body wasn't succesfully parsed/evaluated
  class InvalidRubyResponse < Http
    
  end
  
end