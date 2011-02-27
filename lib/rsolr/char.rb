module RSolr
  module Char
    # Attempts to destructively escape non-word character in a string
    #   @param [String] value Some string
    #   @return [String] The value, escaped
    def escape!(value)
      value.gsub! /(\W)/, '\\\\\1'
    end

    # Attempts to escape non-word character in a string
    #   @param [String] value Some string
    #   @return [String] The value, escaped
    def escape(value)
      escape! value.dup
    end
  end
end
