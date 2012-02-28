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
            doc = RSolr::Document.new(doc) if doc.respond_to?(:each_pair)
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
        end
        add_attrs.map{|k,v| json[k] = v} if add_attrs  # Done down here to game Jsonify's append logic.
        json.compile!
      end
    end
  end
end

