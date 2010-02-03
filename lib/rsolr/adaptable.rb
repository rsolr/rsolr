module RSolr::Adaptable
  
  attr_accessor :adapters, :default_adapter
  
  def adapters
    @adapters ||= {}
  end
  
  def adapter *args, &block
    adapter_type = adapters.include?(args.first) ? args.shift : default_adapter
    opts = args.first
    adapter_factory = adapters[adapter_type]
    adapter_factory.call(opts, block)
  end
  
end