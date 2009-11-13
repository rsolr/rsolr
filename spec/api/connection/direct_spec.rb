if jruby?
  
  describe RSolr::Connection::Direct do
  
    it 'should accept various tpyes of arguments' do
      
      RSolr::Connection::Direct.new({})
      
    end
  
  end
  
end