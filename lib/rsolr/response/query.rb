# response module for queries
module RSolr::Response::Query
  
  # module for adding helper methods to each Hash document
  class Doc < Mash
    
    # Helper method to check if value/multi-values exist for a given key.
    # The value can be a string, or a RegExp
    # Example:
    # doc.has?(:location_facet)
    # doc.has?(:location_facet, 'Clemons')
    # doc.has?(:id, 'h009', /^u/i)
    def has?(k, *values)
      return if self[k].nil?
      return true if self.key?(k) and values.empty?
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
  
  # from the delsolr project -> http://github.com/avvo/delsolr/tree/master/lib/delsolr/response.rb
  module Facets
    
    def facets
      @facets ||= data['facet_counts'] || {}
    end

    # Returns the hash of all the facet_fields (ie: {'instock_b' => ['true', 123, 'false', 20]}
    def facet_fields
      @facet_fields ||= facets['facet_fields'] || {}
    end

    # Returns all of the facet queries
    def facet_queries
      @facet_queries ||= facets['facet_queries'] || {}
    end

    # Returns a hash of hashs rather than a hash of arrays (ie: {'instock_b' => {'true' => 123', 'false', => 20} })
    def facet_fields_by_hash
      @facet_fields_by_hash ||= begin
        f = {}
        if facet_fields
          facet_fields.each do |field,value_and_counts|
            f[field] = {}
            value_and_counts.each_with_index do |v, i|
              if i % 2 == 0
                f[field][v] = value_and_counts[i+1]
              end
            end
          end
        end
        f
      end
    end

    # Returns an array of value/counts for a given field (ie: ['true', 123, 'false', 20]
    def facet_field(field)
      facet_fields[field.to_s]
    end

    # Returns the array of field values for the given field in the order they were returned from solr
    def facet_field_values(field)
      facet_field_values ||= {}
      facet_field_values[field.to_s] ||= begin
        a = []
        return unless facet_field(field)
        facet_field(field).each_with_index do |val_or_count, i|
          a << val_or_count if i % 2 == 0 && facet_field(field)[i+1] > 0
        end
        a
      end
    end

    # Returns a hash of value/counts for a given field (ie: {'true' => 123, 'false' => 20}
    def facet_field_by_hash(field)
      facet_fields_by_hash[field.to_s]
    end

    # Returns the count for the given field/value pair
    def facet_field_count(field, value)
      facet_fields_by_hash[field.to_s][value.to_s] if facet_fields_by_hash[field.to_s]
    end

    # Returns the counts for a given facet_query_name
    def facet_query_count_by_name(facet_query_name)
      query_string = query_builder.facet_query_by_name(facet_query_name)
      facet_queries[query_string] if query_string
    end
    
  end
  
  #
  #
  #
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
  class Base < RSolr::Response::Base
    
    include RSolr::Response::Query::Pagination
    include RSolr::Response::Query::Facets
    
    attr_reader :response, :docs, :num_found, :start
    
    alias :total :num_found
    alias :offset :start
    
    def initialize(data)
      super(data)
      @response = @data[:response]
      @docs = @response[:docs].collect{ |d| Doc.new(d) }
      @num_found = @response[:numFound]
      @start = @response[:start]
    end
  
  end
  
end