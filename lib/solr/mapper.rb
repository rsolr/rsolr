module Solr::Mapper
  
  autoload :RSS, 'solr/mapper/rss'
  
  class UnkownMappingValue < RuntimeError; end
  
  class Base
    
    attr_reader :mapping, :opts
  
    def initialize(mapping={}, opts={}, &block)
      @mapping = mapping
      @opts = opts
      yield @mapping if block_given?
    end
    
    # source - a hash or array of source data
    # override_mapping - an alternate mapper
    # returns an array with one or more mapped hashes
    def map(source, override_mapping=nil)
      source = [source] if source.is_a?(Hash)
      mapping = override_mapping || @mapping
      index = -1
      # collect a bunch of hashes...
      source.collect do |src|
        index += 1
        # for each mapping item, inject data into a new hash
        mapping.inject({}) do |a_new_hash, (map_key, map_value)|
          value = mapped_field_value(src, map_value, index)
          value.to_s.empty? ? a_new_hash : a_new_hash.merge!({map_key=>value})
        end
      end
    end
  
    protected
  
    # This is a hook method useful for subclassing
    def source_field_value(source, field_name, index)
      source[field_name]
    end
  
    def mapped_field_value(source, mapped_value, index)
      case mapped_value
        when String
          mapped_value
        when Symbol
          source_field_value(source, mapped_value, index)
        when Proc
          mapped_value.call(source, index)
        when Enumerable
          mapped_value.collect {|key| source_field_value(source, key, index)}.flatten
        else
          # try to turn it into a string, else raise UnkownMappingValue
          mapped_value.respond_to?(:to_s) ? mapped_value.to_s : raise(UnkownMappingValue.new(mapped_value))
      end
    end
    
  end
  
end