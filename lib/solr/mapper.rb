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
      m = override_mapping || @mapping
      source.collect do |src|
        m.inject({}) do |mapped_data, (field_name, mapped_value)|
          value = mapped_field_value(src, mapped_value)
          value.to_s.empty? ? mapped_data : mapped_data.merge!({field_name=>value})
        end
      end
    end
  
    protected
  
    # This is a hook method useful for subclassing
    def source_field_value(source, field_name)
      source[field_name]
    end
  
    def mapped_field_value(source, mapped_value)
      case mapped_value
        when String
          mapped_value
        when Symbol
          source_field_value(source, mapped_value)
        when Proc
          mapped_value.call(source, self)
        when Enumerable
          mapped_value.collect {|key| source_field_value(source, key)}.flatten
        else
          # try to turn it into a string, else raise UnkownMappingValue
          mapped_value.respond_to?(:to_s) ? mapped_value.to_s : raise(UnkownMappingValue.new(mapped_value))
      end
    end
    
  end
  
end