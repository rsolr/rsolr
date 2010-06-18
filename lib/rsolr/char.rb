# A module that contains (1) string related methods
module RSolr::Char
  
  # escape - from the solr-ruby library
  # RSolr.escape('asdf')
  # backslash everything that isn't a word character
  def escape value
    value.gsub /(\W)/, '\\\\\1'
  end
  
end