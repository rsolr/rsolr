class RSolr::Connection::ParamMapping::Standard
  
  include RSolr::Connection::ParamMapping::MappingMethods
  
  attr_reader :input, :output
  
  def initialize(input)
    @output = {}
    @input = input
    setup_mappings
  end
  
  def setup_mappings
    
    mapping_for :per_page, :rows do |val|
      val = val.to_s.to_i
      val < 0 ? 0 : val
    end
    
    mapping_for :page, :start do |val|
      val = val.to_s.to_i
      page = val > 0 ? val : 1
      ((page - 1) * (@output[:rows] || 0))
    end
    
    mapping_for :queries, :q do |val|
      format_query(val)
    end
    
    mapping_for :phrase_queries, :q do |val|
      values = [@output[:q], format_query(val, true)]
      # remove blank items
      values.reject!{|v|v.to_s.empty?}
      # join all items on a space
      values.join(' ')
    end
    
    mapping_for :filters, :fq do |val|
      format_query(val)
    end
    
    # this must come after the :filter/:fq mapper
    mapping_for :phrase_filters, :fq do |val|
      # use the previously set fq queries and generate the new phrased based ones
      values = [@output[:fq], format_query(val, true)]
      # flatten (need to do this because the previous fq could have been an array)
      values = values.flatten
      # remove blank items
      values.reject!{|v|v.to_s.empty?} # don't join -- instead create multiple fq params
      # don't join... fq needs to be an array so multiple fq params are sent to solr
      values
    end
    
    mapping_for :facets do |input|
      next if input.to_s.empty?
      @output[:facet] = true
      @output['facet.field'] = []
      if input[:queries]
        # convert to an array if needed
        input[:queries] = [input[:queries]] unless input[:queries].is_a?(Array)
        @output[:facet.query] = input[:queries].map{|q|format_query(q)}
      end
      common_sub_fields = [:sort, :limit, :missing, :mincount, :prefix, :offset, :method, 'enum.cache.minDf']
      (common_sub_fields).each do |subfield|
        next unless input[subfield]
        @output["facet.#{subfield}"] = input[subfield]
      end
      if input[:fields]
        input[:fields].each do |f|
          if f.kind_of? Hash
            key = f.keys[0]
            value = f[key]
            @output[:facet.field] << key
            common_sub_fields.each do |subfield|
              next unless value[subfield]
              @output["f.#{key}.facet.#{subfield}"] = input[subfield]
            end
          else
            @output['facet.field'] << f
          end
        end
      end
    end
  end
  
  # takes an input and returns a formatted value
  def format_query(input, quote=false)
    case input
    when Array
      format_array_query(input, quote)
    when Hash
      format_hash_query(input, quote)
    else
      prep_value(input, quote)
    end
  end
  
  def format_array_query(input, quote)
    input.collect do |v|
      v.is_a?(Hash) ? format_hash_query(v, quote) : prep_value(v, quote)
    end
  end
  
  # groups values to a single field: title:(value1 value2) instead of title:value1 title:value2
  # a value can be a range or a string
  def format_hash_query(input, quote=false)
    q = []
    input.each_pair do |field,value|
      next if value.to_s.empty? # skip blank values!
      # create the field plus the delimiter if the field is not blank
      value = [value] unless value.is_a?(Array)
      fielded_queries = value.collect do |vv|
        vv.is_a?(Range) ? "[#{vv.min} TO #{vv.max}]" : prep_value(vv, quote)
      end
      field = field.to_s.empty? ? '' : "#{field}:"
      fielded_queries.each do |fq|
        q << "#{field}(#{fq})"
      end
    end
    q
  end
  
  def prep_value(val, quote=false)
    quote ? %(\"#{val}\") : val.to_s
  end
  
end