#
# Xout is a simple XML generator
# http://github.com/mwmitchell/xout/tree/master
#
class Xout
  
  attr_reader :name, :text, :attrs, :block, :children

  def initialize(node_name, text=nil, attrs={}, &block)
    @children=[]
    if text.is_a?(Hash)
      attrs=text
      text=nil
    end
    @name, @text, @attrs, @block = node_name, text, attrs, block
  end

  def child(name, text=nil, attrs={}, &block)
    add_child Xout.new(name, text, attrs, &block)
  end
  
  def add_child(node)
    children << node
    node
  end

  def children?; children.size>0 end

  def to_s
    xml = to_xml
  end

  def to_xml
    xml = "<#{name}#{create_attrs(attrs)}"
    block.call(self) if block
    if text || children?
      xml += ">#{escape text.to_s}"
      xml += children.map{|child|child.to_xml}.join
      xml += "</#{name}>"
    else
      xml += '/>'
    end
    xml
  end
  
  def to_xml_doc
    '<?xml version="1.0" encoding="UTF-8"?>' + to_s
  end
  
  protected
  
  def create_attrs(hash)
    hash.inject(['']) do |acc,(k,v)|
      acc << "#{k}=\"#{escape v.to_s}\""
    end.join(' ')
  end
  
  def escape(input)
    XChar.xs(input)
    #input.to_s.gsub('&', '&amp;').
    #  gsub('<', '&lt;').
    #    gsub('>', '&gt;').
    #      gsub("'", '&apos;').
    #        gsub('"', '&quote;')
  end
  
  ####################################################################
  # XML Character converter, from Sam Ruby:
  # (see http://intertwingly.net/stories/2005/09/28/xchar.rb). 
  #
  module XChar # :nodoc:

    # See
    # http://intertwingly.net/stories/2004/04/14/i18n.html#CleaningWindows
    # for details.
    CP1252 = {			# :nodoc:
      128 => 8364,		# euro sign
      130 => 8218,		# single low-9 quotation mark
      131 =>  402,		# latin small letter f with hook
      132 => 8222,		# double low-9 quotation mark
      133 => 8230,		# horizontal ellipsis
      134 => 8224,		# dagger
      135 => 8225,		# double dagger
      136 =>  710,		# modifier letter circumflex accent
      137 => 8240,		# per mille sign
      138 =>  352,		# latin capital letter s with caron
      139 => 8249,		# single left-pointing angle quotation mark
      140 =>  338,		# latin capital ligature oe
      142 =>  381,		# latin capital letter z with caron
      145 => 8216,		# left single quotation mark
      146 => 8217,		# right single quotation mark
      147 => 8220,		# left double quotation mark
      148 => 8221,		# right double quotation mark
      149 => 8226,		# bullet
      150 => 8211,		# en dash
      151 => 8212,		# em dash
      152 =>  732,		# small tilde
      153 => 8482,		# trade mark sign
      154 =>  353,		# latin small letter s with caron
      155 => 8250,		# single right-pointing angle quotation mark
      156 =>  339,		# latin small ligature oe
      158 =>  382,		# latin small letter z with caron
      159 =>  376,		# latin capital letter y with diaeresis
    }

    # See http://www.w3.org/TR/REC-xml/#dt-chardata for details.
    PREDEFINED = {
      34 => '&quot;', # quotation mark
      38 => '&amp;',		# ampersand
      60 => '&lt;',		# left angle bracket
      62 => '&gt;',		# right angle bracket
    }

    # See http://www.w3.org/TR/REC-xml/#charsets for details.
    VALID = [
      [0x9, 0xA, 0xD],
      (0x20..0xD7FF), 
      (0xE000..0xFFFD),
      (0x10000..0x10FFFF)
    ]
    
    def self.xchar(int)
      n = CP1252[int] || int
      n = 42 unless VALID.find {|range| range.include? n}
      PREDEFINED[n] or (n<128 ? n.chr : "&##{n};")
    end
    
    def self.xs(string)
      string.unpack('U*').map {|n| xchar(n) }.join # ASCII, UTF-8
    rescue
      string.unpack('C*').map {|n| xchar(n) }.join # ISO-8859-1, WIN-1252
    end
    
  end
  
end