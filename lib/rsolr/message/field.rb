# A class that represents a "doc"/"field" xml element for a solr update
class RSolr::Message::Field
  
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