module RSolr::Error
  
  module Printable
    
    attr_accessor :request_context, :response_context
    
    def to_s
      m = "\n#{super.to_s}:"
      m << "\n" + self.backtrace[0..5].join("\n")
      m << "\n\nSolr Request:"
      m << "\n  Method: #{request_context[:method].to_s.upcase}"
      m << "\n  Base URL: #{request_context[:connection].uri.to_s}"
      m << "\n  URL: #{request_context[:uri]}"
      m << "\n  Params: #{request_context[:params].inspect}"
      m << "\n  Data: #{request_context[:data].inspect}" if request_context[:data]
      m << "\n  Headers: #{request_context[:headers].inspect}"
      if response_context
        m << "\n\nSolr Response:"
        m << "\n  Code: #{response_context[0]}"
        m << "\n  Headers: #{response_context[1].inspect}"
        details = parse_solr_error_response response_context[2]
        m << "\n  Details:\n#{details}" if details
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
    
    include Printable
    
    def initialize request, response
      @request_context, @response_context = request, response
    end
    
  end
  
end