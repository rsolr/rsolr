# =Example
#
# mapping = {
#   :id => lambda{|doc,i|"doc-#{i}"},
#   :name_s => :name,
#   :amenities => lambda {|mongo_doc,index|
#     mongo_doc.amenities.map{|a| a.name }
#   }
# }
# 
# module LowercaseFilter
#   def map_field doc, index, field, value
#     mapped_value = super
#     mapped_value.respond_to?(:downcase) ? mapped_value.downcase : mapped_value
#   end
# end
# 
# mapper.extend LowercaseFilter
# 
# mapper = Mapper.new mapping
# 
# require 'ostruct'
# 
# docs = 10.times.map do |i|
#   amenities = [OpenStruct.new(:name => "amenity #{i}")]
#   OpenStruct.new(:name=>"name #{i}", :amenities => amenities)
# end
# 
# mapper.map docs do |mapped_doc|
#   puts mapped_doc.inspect
# end
#
class RSolr::Mapper
  
  attr :mapping
  
  def initialize mapping
    @mapping = mapping
  end
  
  def map docs, &block
    index = 0
    docs.each do |doc|
      yield map_document(doc, index), index
      index += 1
    end
  end
  
  def map_document doc, index
    mapping.inject({}) do |mapped_doc, (field, value)|
      mapped_doc.merge field => map_field(doc, index, field, value)
    end
  end
  
  def map_field doc, index, field, value
    case value
    when Proc
      value.call doc, index
    when Symbol
      doc.send value
    else
      value
    end
  end
  
end