class Solr::Indexer
  
  attr_reader :solr, :mapper, :opts
  
  def initialize(solr, mapping_or_mapper, opts={})
    @solr = solr
    @mapper = mapping_or_mapper.is_a?(Hash) ? Solr::Mapper::Base.new(mapping_or_mapper) : mapping_or_mapper
    @opts = opts
  end
  
  # data - the raw data to send into the mapper
  # params - url query params for solr /update handler
  # commit - boolean; true==commit after adding, false==no commit after adding
  # block can be used for modifying the "add", "doc" and "field" xml elements (for boosting etc.)
  def index(data, params={}, &block)
    docs = data.collect {|d| @mapper.map(d)}
    @solr.add(docs, params) do |add, doc, field|
      # check opts for :debug etc.?
      yield add, doc, field if block_given?
    end
  end
  
end