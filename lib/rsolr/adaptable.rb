module RSolr::Adaptable
    
  attr_accessor :adapters, :default_adapter
  
  def adapters
    @adapters ||= {}
  end
  
  def adapter *args, &block
    opts = args.pop if args.last.is_a?(Hash)
    adapter_type = args.first || default_adapter
    adapter_factory = adapters[adapter_type]
    adapter_factory.call opts, &block
  end
  
end