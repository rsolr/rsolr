class Xout
  
  attr_reader :name, :text, :attrs, :children
  
  def initialize node_name, *args, &block
    @children = []
    attrs = args.last.is_a?(Hash) ? args.pop : {}
    text = args.empty? ? '' : args.pop.to_s
    @name, @text, @attrs = node_name, text, attrs
    yield self if block_given?
  end
  
  def child name, *args, &block
    add_child self.class.new(name, *args, &block)
  end
  
  def add_child node
    children << node
  end
  
  def to_xml
    xml = ["<#{name}#{create_attrs(attrs)}"]
    if not text.empty? or not children.empty?
      xml << ">#{escape_text text.to_s}"
      xml += children.map{|child|child.to_xml}
      xml << "</#{name}>"
    else
      xml << '/>'
    end
    xml.join
  end
  
  alias :to_s :to_xml
  
  def to_xml_doc
    '<?xml version="1.0" encoding="UTF-8"?>' + to_xml
  end
  
  protected
  
  # builds an XML attribute string.
  # escapes each attribute value by running it through #escape_attr
  def create_attrs hash
    r = hash.map { |k,v| "#{k}=\"#{escape_attr v.to_s}\"" }.join(' ')
    " #{r}" unless r.empty?
  end
  
  # minimal escaping for attribute values
  def escape_attr input
    escape input, '&'=>'&amp;', '<'=>'&lt;', '>'=>'&gt;', "'"=>'&apos;', '"'=>'&quote;'
  end
  
  # minimal escaping for text
  def escape_text input
    escape input, '&'=>'&amp;', '<'=>'&lt;', '>'=>'&gt;'
  end
  
  # accepts a string input and a hash mapping of characters => replacement values:
  # Example:
  #   escape 'My <string>cat</strong>', '<'=>'&gt;', '>'=>'&lt;'
  def escape input, map
    input.gsub(/[#{map.keys.join}]+/) { | char | map[char] || char }
  end
  
end