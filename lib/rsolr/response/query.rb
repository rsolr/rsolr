# response module for queries
module RSolr::Response::Query
  
  # module for adding helper methods to each Hash document
  module DocExt
    
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
    
    # helper
    # key is the name of the field
    # opts is a hash with the following valid keys:
    #  - :sep - a string used for joining multivalued field values
    #  - :default - a value to return when the key doesn't exist
    # if :sep is nil and the field is a multivalued field, the array is returned
    def get(key, opts={:sep=>', ', :default=>nil})
      if self.key? key
        val = self[key]
        (val.is_a?(Array) and opts[:sep]) ? val.join(opts[:sep]) : val
      else
        opts[:default]
      end
    end
    
  end
  
  # from the delsolr project -> http://github.com/avvo/delsolr/tree/master/lib/delsolr/response.rb
  module Facets
    
    class FacetValue
      attr_reader :value,:hits
      def initialize(value,hits)
        @value,@hits=value,hits
      end
    end
    
    class Facet
      attr_reader :field
      attr_accessor :values
      def initialize(field)
        @field=field
        @values=[]
      end
    end
    
    # @response.facet_fields.each do |facet|
    #   facet.field
    # end
    # "caches" the result in the @facets instance var
    def facets
      @facets ||= (
        facet_fields.inject([]) do |acc,(facet_field_name,values_and_hits_list)|
          acc << facet = Facet.new(facet_field_name)
          # the values_and_hits_list is an array where a value is immediately followed by it's hit count
          # so we shift off an item (the value)
          while value = values_and_hits_list.shift
            # and then shift off the next to get the hit value
            facet.values << FacetValue.new(value, values_and_hits_list.shift)
            # repeat until there are no more pairs in the values_and_hits_list array
          end
          acc
        end
      )
    end
    
    # pass in a facet field name and get back a Facet instance
    def facet_by_field_name(name)
      facets.detect{|facet|facet.field.to_s == name.to_s}
    end
    
    def facet_counts
      @facets ||= data['facet_counts'] || {}
    end
    
    # Returns the hash of all the facet_fields (ie: {'instock_b' => ['true', 123, 'false', 20]}
    def facet_fields
      @facet_fields ||= facet_counts['facet_fields'] || {}
    end
    
    # Returns all of the facet queries
    def facet_queries
      @facet_queries ||= facet_counts['facet_queries'] || {}
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
      @docs = @response[:docs].collect{ |d| d=d.to_mash; d.extend(DocExt); d }
      @num_found = @response[:numFound]
      @start = @response[:start]
    end
  
  end
  
end