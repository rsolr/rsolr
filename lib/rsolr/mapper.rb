# mapper = RSolr::Mapper.new do
#   field :id
#   field [:name_ss,:name_text], :name
#   field [:address_ss,:address_text], :addres1
#   field :address, :addres1
#   field :state do
#     current.state.to_s.strip.downcase
#   end
#   after do |record|
#     
#   end
# end
# 
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
# 
# mapper = Mapper.new mapping
# 
# mapped.after do |doc,index|
#   doc.each_pair {|k,v|
#     doc[k] = v.respond_to?(:downcase) ? v.downcase : v
#     doc["#{k}_text"] = v
#   }
# end
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
  
  #
  def initialize mapping
    @mapping = mapping
  end
  
  #
  def map docs, &block
    docs = [docs] unless docs.is_a?(Array)
    index = 0
    docs.each do |doc|
      yield map_document(doc, index), index
      index += 1
    end
  end
  
  # #map_document yields the current incoming doc to this block.
  def before &block
    @before_map_block = block
  end
  
  # #map_document yields the mapped doc to this block.
  def after &block
    @after_map_block = block
  end
  
  #
  def map_document doc, index
    @before_map_block.call(doc, index) if @before_map_block
    mapped_doc = mapping.inject({}) do |mapped_doc, (field, value)|
      mapped_doc.merge field => map_field(doc, index, field, value)
    end
    @after_map_block.call(mapped_doc, index) if @after_map_block
    mapped_doc
  end
  
  #
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