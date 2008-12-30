# response module for queries
module Solr::Response::Query
  
  # module for adding helper methods to each Hash document
  module DocExt
    
    def self.extended(base)
      base.keys.each do |k,v|
        base.instance_eval <<-EOF
        def #{k}; self['#{k.to_s}']; end
        EOF
      end
    end
    
    # Helper method to check if value/multi-values exist for a given key.
    # The value can be a string, or a RegExp
    # Example:
    # doc.has?(:location_facet)
    # doc.has?(:location_facet, 'Clemons')
    # doc.has?(:id, 'h009', /^u/i)
    def has?(k, *values)
      return if self[k].nil?
      return true if self.has_key?(k) and values.empty?
      target = self[k]
      if target.is_a?(Array)
        values.each do |val|
          return target.any?{|tv| val.is_a?(Regexp) ? (tv =~ val) : (tv==val)}
        end
      else
        return values.any? {|val| val.is_a?(Regexp) ? (target =~ val) : (target == val)}
      end
    end

  end
  
  module Pagination
    
    # alias to the Solr param, 'rows'
    def per_page
      @per_page ||= params['rows'].to_s.to_i
    end
    
    # Returns the current page calculated from 'rows' and 'start'
    # WillPaginate hook
    def current_page
      @current_page ||= (self.start / self.per_page).ceil + 1
    end
    
    # Calcuates the total pages from 'numFound' and 'rows'
    # WillPaginate hook
    def total_pages
      @total_pages ||= self.per_page > 0 ? (self.total / self.per_page.to_f).ceil : 1
    end
    
    # returns the previous page number or 1
    # WillPaginate hook
    def previous_page
      @previous_page ||= (current_page > 1) ? current_page - 1 : 1
    end
    
    # returns the next page number or the last
    # WillPaginate hook
    def next_page
      @next_page ||= (current_page < total_pages) ? current_page + 1 : total_pages
    end
    
  end
  
  # The base query response class
  # adds to the Solr::Response::Base class by defining a few more attributes,
  # includes the Pagination module, and extends each of the doc hashes
  # with Solr::Response::Query::DocExt
  class Base < Solr::Response::Base
    
    include Solr::Response::Query::Pagination
    
    attr_reader :response, :docs, :num_found, :start
  
    alias :total :num_found
    alias :offset :start
  
    def initialize(data)
      super(data)
      @response = @data['response']
      @docs = @response['docs']
      @docs.each do |d|
        d.extend Solr::Response::Query::DocExt
      end
      @num_found = @response['numFound']
      @start = @response['start']
    end
  
  end
  
end