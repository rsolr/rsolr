# A class that represents a "doc" xml element for a solr update
class RSolr::Message::Document
  
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
        @fields << RSolr::Message::Field.new({:name=>field}, v.to_s)
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
    @fields << RSolr::Message::Field.new(options.merge({:name=>name}), value)
  end
  
end