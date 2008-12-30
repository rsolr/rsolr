module Solr::Connection::SearchExt
  
  def search(q_param, params={})
    if params[:fields]
      fields = params.delete :fields
      params[:fl] = fields.is_a?(Array) ? fields.join(' ') : fields
    end
    
    # adds quoted values to the :filters hash
    if params[:phrase_filters]
      phrase_filters = params.delete(:phrase_filters)
      params[:filters] ||= {}
      phrase_filters.each do |filter,values|
        params[:filters][filter] ||= []
        values.each do |v|
          params[:filters][filter] << "\"#{v}\""
        end
      end
    end
    
    params[:fq] = build_filters(params.delete(:filters)) if params[:filters]
    facets = params.delete(:facets) if params[:facets]
    
    if facets
      if facets.is_a?(Array)
        params.merge!({:facet => true})
        params.merge! build_facets(facets)          
      elsif facets.is_a?(Hash)
        params.merge!({:facet => true})
        #params += build_facet(facets)
      elsif facets.is_a?(String)
        #params += facets
      else
        raise 'facets must either be a Hash or an Array'
      end
    end
    #params[:qt] ||= :dismax
    params[:q] = build_query(q_param)
    self.query params
  end
  
  protected
  
  # returns the query param
  def build_query(queries)
    query_string = ''
    case queries
    when String
      query_string = queries
    when Array
      query_string = queries.join(' ')
    when Hash
      query_string_array = []
      queries.each do |k,v|
        if v.is_a?(Array) # add a filter for each value
          v.each do |val|
            query_string_array << "#{k}:#{val}"
          end
        elsif v.is_a?(Range)
          query_string_array << "#{k}:[#{v.min} TO #{v.max}]"
        else
          query_string_array << "#{k}:#{v}"
        end
      end
      query_string = query_string_array.join(' ')
    end
    query_string
  end

  def build_filters(filters)
    params = []
    # handle "ruby-ish" filters
    case filters
    when String
      params << filters
    when Array
      filters.each { |f| params << f }
    when Hash
      filters.each do |k,v|
        if v.is_a?(Array) # add a filter for each value
          v.each do |val|
            params << "#{k}:#{val}"
          end
        elsif v.is_a?(Range)
          params << "#{k}:[#{v.min} TO #{v.max}]"
        else
          params << "#{k}:#{v}"
        end
      end
    end
    params
  end
  
  def build_facets(facet_array)
    facet_array.inject({}) do |p, facet_hash|
      build_facet(facet_hash).each {|k| p.merge!(k) }
      p
    end
  end

  def build_facet(facet_hash)
    params = []
    facet_name = facet_hash['name'] || facet_hash[:name]
    facet_hash.each do |k,v|
      # handle some cases specially
      if 'field' == k.to_s
        params << {"facet.field" => v}
      elsif 'query' == k.to_s
        q = build_query(v)
        params << {"facet.query"=>q}
        if facet_name
          # keep track of names => facet_queries
          name_to_facet_query[facet_name] = q['facet.query']
        end
      else
        params << {"f.#{facet_hash[:field]}.facet.#{k}" => v}
      end
    end
    params
  end
  
  def name_to_facet_query
    @name_to_facet_query ||= {}
  end

end