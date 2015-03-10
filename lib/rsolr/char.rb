# A module that contains (1) string related methods
# @deprecated remove this module when we remove the method (duh)
module RSolr::Char
  
  # backslash everything
  # that isn't a word character
  # @deprecated - this is incorrect Solr escaping
  def escape value
    warn "[DEPRECATION] `RSolr.escape` is deprecated (and incorrect).  Use `RSolr.solr_escape` instead."
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
