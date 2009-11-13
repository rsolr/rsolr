describe RSolr do
  
  def new_client
    RSolr::Client.new Object.new
  end
  
  context "method_missing" do
    
    it 'a non-existent method should be forwarded to #method_missing and then to #request' do
      client = new_client
      client.should_receive(:request).
        with('/music', :q=>'Coltrane')
      client.music :q=>'Coltrane'
    end
    
  end
  
  context 'update' do
    
    it 'should forward /update to #request("/update")' do
      client = new_client
      client.should_receive(:request).
        with('/update', {}, '<commit/>')
      client.update '<commit/>'
    end
    
    it 'should forward #add calls to #update' do
      client = new_client
      client.should_receive(:update).
        with('<add><doc><field name="id">1</field></doc></add>')
      client.add :id=>1
    end
    
    it 'should forward #commit calls to #update' do
      client = new_client
      client.should_receive(:update).
        with('<commit/>')
      client.commit
    end
    
    it 'should forward #optimize calls to #update' do
      client = new_client
      client.should_receive(:update).
        with('<optimize/>')
      client.optimize
    end
    
    it 'should forward #rollback calls to #update' do
      client = new_client
      client.should_receive(:update).
        with('<rollback/>')
      client.rollback
    end
    
    it 'should forward #delete_by_id calls to #update' do
      client = new_client
      client.should_receive(:update).
        with('<delete><id>1</id></delete>')
      client.delete_by_id 1
    end
    
    it 'should forward #delete_by_query calls to #update' do
      client = new_client
      client.should_receive(:update).
        with('<delete><query>blah</query></delete>')
      client.delete_by_query 'blah'
    end
    
  end
  
  context 'request' do
    
    it 'should forward #request calls to the connection' do
      client = new_client
      client.connection.should_receive(:request).
        with('/music', :q=>'Coltrane', :wt=>:ruby).
          # empty params so that Client doesn't try to evalulate to Ruby;
          #   -- this happens if the :wt equal :ruby
          and_return(:params=>{})
      client.request '/music', :q=>'Coltrane'
    end
    
  end
  
  context 'adapt_response' do
    
    it 'should not try to evaluate ruby when the :qt is not :ruby' do
      client = new_client
      body = '{:time=>"NOW"}'
      result = client.send(:adapt_response, {:body=>body, :params=>{}})
      result.should be_a(String)
      result.should == body
    end
    
    it 'should evaluate ruby responses when the :wt is :ruby' do
      client = new_client
      body = '{:time=>"NOW"}'
      result = client.send(:adapt_response, {:body=>body, :params=>{:wt=>:ruby}})
      result.should be_a(Hash)
      result.should == {:time=>"NOW"}
    end
    
  end
  
end