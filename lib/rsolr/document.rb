module RSolr
  class Document
    CHILD_DOCUMENT_KEY = '_childDocuments_'.freeze

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
      RSolr::Array.wrap(values).each do |v|
        next if v.nil?

        field_attrs = { name: name }
        field_attrs[:type] = DocumentField if name.to_s == CHILD_DOCUMENT_KEY

        @fields << RSolr::Field.instance(options.merge(field_attrs), v)
      end
    end

    def as_json
      @fields.group_by(&:name).each_with_object({}) do |(field, values), result|
        v = values.map(&:as_json)
        v = v.first if v.length == 1 && field.to_s != CHILD_DOCUMENT_KEY
        result[field] = v
      end
    end
  end

  class Field

    def self.instance(attrs, value)
      attrs = attrs.dup
      field_type = attrs.delete(:type) {  value.class.name }

      klass = if field_type.is_a? String
                class_for_field(field_type)
              elsif field_type.is_a? Class
                field_type
              else
                self
              end

      klass.new(attrs, value)
    end

    def self.class_for_field(field_type)
      potential_class_name = field_type + 'Field'.freeze
      search_scope = Module.nesting[1]
      search_scope.const_defined?(potential_class_name, false) ? search_scope.const_get(potential_class_name) : self
    end
    private_class_method :class_for_field

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
      source_value
    end

    def as_json
      if attrs[:update]
        { attrs[:update] => value }
      elsif attrs.any? { |k, _| k != :name }
        hash = attrs.dup
        hash.delete(:name)
        hash.merge(value: value)
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

  class DocumentField < Field
    def value
      return RSolr::Document.new(source_value) if source_value.respond_to? :each_pair

      super
    end

    def as_json
      value.as_json
    end
  end
end
