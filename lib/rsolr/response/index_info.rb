# response for /admin/luke
class RSolr::Response::IndexInfo < RSolr::Response::Base
  
  attr_reader :index, :directory, :has_deletions, :optimized, :current, :max_doc, :num_docs, :version
  
  alias :has_deletions? :has_deletions
  alias :optimized? :optimized
  alias :current? :current
  
  def initialize(data)
    super(data)
    @index = @data[:index]
    @directory = @data[:directory]
    # index fields
    @has_deletions = @index[:hasDeletions]
    @optimized = @index[:optimized]
    @current = @index[:current]
    @max_doc = @index[:maxDoc]
    @num_docs = @index[:numDocs]
    @version = @index[:version]
  end
  
  # Returns an array of fields from the index
  # An optional rule can be used for "grepping" field names:
  # field_list(/_facet$/)
  def field_list(rule=nil)
    @data[:fields].select do |k,v|
      rule ? k =~ rule : true
    end.collect{|k,v|k}
  end
  
  
end