require 'jsonify'

module RSolr::JSON
  class Generator
    def build &block
      b = Jsonify::Builder.new(:format => :pretty)
      block_given? ? yield(b) : b
    end

    def add data, add_attrs = nil, &block
      data = [data] unless data.is_a?(Array)
      build do |json|
        json.add do
          json.doc data do |doc|
            doc = RSolr::JSON::Document.new(doc) if doc.respond_to?(:each_pair)
            yield doc if block_given?
            # json << doc.attrs if doc.attrs
            doc.fields.each do |f|
              if f.attrs.keys.length > 1
                json[f.name] = f.attrs.merge(:value => f.value)
              else
                json[f.name] = f.value
              end
            end
          end
          add_attrs.map{|k,v| json[k] = v} if add_attrs  # Done down here to game Jsonify's append logic.
        end
        json.compile!
      end
    end
  end

  class Document < RSolr::Document
    def initialize(doc_hash = {})
      @fields = []
      @attrs = {}
      doc_hash.each_pair do |field, values|
        vals = values.is_a?(Array) ? values.map(&:to_s) : values
        @fields << RSolr::Field.new({:name => field}, vals)
      end
    end
  end
end

