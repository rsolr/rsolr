module RSolr::Connection::ParamMapping
  
  autoload :Standard, 'rsolr/connection/param_mapping/standard'
  autoload :Dismax, 'rsolr/connection/param_mapping/dismax'
  
  module MappingMethods
    
    def mappers
      @mappers ||= []
    end
    
    def mapping_for(user_param_name, solr_param_name=nil, &block)
      return unless @input[user_param_name]
      if (m = self.mappers.detect{|m|m[:input_name] == user_param_name})
        self.mappers.delete m
      end
      self.mappers << {:input_name=>user_param_name, :output_name=>solr_param_name, :block=>block}
    end
    
    def map(&blk)
      input = @input.dup
      mappers.each do |m|
      input_value = input[m[:input_name]]
        input.delete m[:input_name]
        if m[:block]
          value = m[:block].call(input_value)
        else
          value = input_value
        end
        if m[:output_name]
          @output[m[:output_name]] = value
        end
      end
      @output.merge(input)
    end
    
  end
  
end