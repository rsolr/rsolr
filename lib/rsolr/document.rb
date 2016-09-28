module RSolr
  class Document
    
    # "attrs" is a hash for setting the "doc" xml attributes
    # "fields" is an array of Field objects
    attr_accessor :attrs, :fields

    # "doc_hash" must be a Hash/Mash object
    # If a value in the "doc_hash" is an array,
    # a field object is created for each value...
    def initialize(doc_hash = {})
      @fields = []
      doc_hash.each_pair do |field, values|
        add_field(field, values)
      end
      @attrs={}
    end

    # returns an array of fields that match the "name" arg
    def fields_by_name(name)
      @fields.select{|f|f.name==name}
    end

    # returns the *first* field that matches the "name" arg
    def field_by_name(name)
      @fields.detect{|f|f.name==name}
    end

    #
    # Add a field value to the document. Options map directly to
    # XML attributes in the Solr <field> node.
    # See http://wiki.apache.org/solr/UpdateXmlMessages#head-8315b8028923d028950ff750a57ee22cbf7977c6
    #
    # === Example:
    #
    #   document.add_field('title', 'A Title', :boost => 2.0)
    #
    def add_field(name, values, options = {})
      wrap(values).each do |v|
        next if v.nil?
        @fields << RSolr::Field.instance(options.merge({:name=>name}), v)
      end
    end

    def as_json
      @fields.each_with_object({}) do |field, result|
        result[field.name] = field.as_json
      end
    end

    private

    def wrap(object)
      if object.nil?
        []
      elsif object.respond_to?(:to_ary)
        object.to_ary || [object]
      elsif object.is_a? Enumerable
        object
      else
        [object]
      end
    end
  end

  class Field

    def self.instance(attrs, value)
      field_type = attrs.fetch(:type, value.class.name) + "Field"
      search_scope = Module.nesting[1]
      klass = search_scope.const_defined?(field_type, false) ? search_scope.const_get(field_type) : Field
      klass.new(attrs, value)
    end

    # "attrs" is a hash for setting the "doc" xml attributes
    # "value" is the text value for the node
    attr_accessor :attrs, :source_value

    # "attrs" must be a hash
    # "value" should be something that responds to #_to_s
    def initialize(attrs, source_value)
      @attrs = attrs
      @source_value = source_value
    end

    # the value of the "name" attribute
    def name
      attrs[:name]
    end

    def value
      source_value.to_s
    end

    def as_json
      if attrs.any? { |k, _| k != :name }
        attrs.merge(value: value)
      else
        value
      end
    end
  end

  class DateField < Field
    def value
      Time.utc(source_value.year, source_value.mon, source_value.mday).iso8601
    end
  end

  class TimeField < Field
    def value
      source_value.getutc.strftime('%FT%TZ')
    end
  end

  class DateTimeField < Field
    def value
      source_value.to_time.getutc.iso8601
    end
  end
end
