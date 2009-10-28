# The Solr::Message class is the XML generation module for sending updates to Solr.

module RSolr::Message
  
  # A class that represents a "doc" xml element for a solr update
  class Document
    
    # "attrs" is a hash for setting the "doc" xml attributes
    # "fields" is an array of Field objects
    attr_accessor :attrs, :fields
    
    # "doc_hash" must be a Hash/Mash object
    # If a value in the "doc_hash" is an array,
    # a field object is created for each value...
    def initialize(doc_hash = {})
      @fields = []
      doc_hash.each_pair do |field,values|
        # create a new field for each value (multi-valued)
        # put non-array values into an array
        values = [values] unless values.is_a?(Array)
        values.each do |v|
          next if v.to_s.empty?
          @fields << Field.new({:name=>field}, v.to_s)
        end
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
    def add_field(name, value, options = {})
      @fields << Field.new(options.merge({:name=>name}), value)
    end
    
  end
  
  # A class that represents a "doc"/"field" xml element for a solr update
  class Field
    
    # "attrs" is a hash for setting the "doc" xml attributes
    # "value" is the text value for the node
    attr_accessor :attrs, :value
    
    # "attrs" must be a hash
    # "value" should be something that responds to #_to_s
    def initialize(attrs, value)
      @attrs = attrs
      @value = value
    end
    
    # the value of the "name" attribute
    def name
      @attrs[:name]
    end
    
  end
  
  class Builder
    
    # generates "add" xml for updating solr
    # "data" can be a hash or an array of hashes.
    # - each hash should be a simple key=>value pair representing a solr doc.
    # If a value is an array, multiple fields will be created.
    #
    # "add_attrs" can be a hash for setting the add xml element attributes.
    # 
    # This method can also accept a block.
    # The value yielded to the block is a Message::Document; for each solr doc in "data".
    # You can set xml element attributes for each "doc" element or individual "field" elements.
    #
    # For example:
    #
    # solr.add({:id=>1, :nickname=>'Tim'}, {:boost=>5.0, :commitWithin=>1.0}) do |doc_msg|
    #   doc_msg.attrs[:boost] = 10.00 # boost the document
    #   nickname = doc_msg.field_by_name(:nickname)
    #   nickname.attrs[:boost] = 20 if nickname.value=='Tim' # boost a field
    # end
    #
    # would result in an add element having the attributes boost="10.0"
    # and a commitWithin="1.0".
    # Each doc element would have a boost="10.0".
    # The "nickname" field would have a boost="20.0"
    # if the doc had a "nickname" field with the value of "Tim".
    #
    def add(data, add_attrs={})
      data = [data] unless data.is_a?(Array)
      add = Xout.new :add, add_attrs
      data.each do |doc|
        doc = Document.new(doc) if doc.respond_to?(:each_pair)
        yield doc if block_given?
        add.child :doc, doc.attrs do |doc_node|
          doc.fields.each do |field_obj|
            doc_node.child :field, field_obj.value, field_obj.attrs
          end
        end
      end
      add.to_xml
    end
    
    # generates a <commit/> message
    def commit(opts={})
      Xout.new(:commit, opts).to_xml
    end
    
    # generates a <optimize/> message
    def optimize(opts={})
      Xout.new(:optimize, opts).to_xml
    end
    
    # generates a <rollback/> message
    def rollback
      Xout.new(:rollback).to_xml
    end
    
    # generates a <delete><id>ID</id></delete> message
    # "ids" can be a single value or array of values
    def delete_by_id(ids)
      ids = [ids] unless ids.is_a?(Array)
      delete_node = Xout.new(:delete) do |xml|
        ids.each { |id| xml.child :id, id }
      end
      delete_node.to_xml
    end
    
    # generates a <delete><query>ID</query></delete> message
    # "queries" can be a single value or an array of values
    def delete_by_query(queries)
      queries = [queries] unless queries.is_a?(Array)
      delete_node = Xout.new(:delete) do |xml|
        queries.each { |query| xml.child :query, query }
      end
      delete_node.to_xml
    end
    
  end
  
end