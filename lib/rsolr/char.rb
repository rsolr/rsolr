# A module that contains (1) string related methods
module RSolr::Char
  
  # backslash everything
  # that isn't a word character
  def escape value
    value.gsub(/(\W)/, '\\\\\1')
  end
  
  # LUCENE_CHAR_RX = /([\+\-\!\(\)\[\]\^\"\~\*\?\:\\]+)/
  # LUCENE_WORD_RX = /(OR|AND|NOT)/
  # 
  # # More specific/lucene escape sequence
  # def lucene_escape string
  #   delim = " "
  #   string.gsub(LUCENE_CHAR_RX, '\\\\\1').split(delim).map { |v|
  #     v.gsub(LUCENE_WORD_RX, '\\\\\1')
  #   }.join(delim)
  # end
  
end