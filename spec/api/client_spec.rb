describe RSolr::Client do
  
  let(:client){ RSolr::Client.new('') }
  
  context :method_missing do
    
    it 'a non-existent method should be forwarded to #method_missing and then to #request' do
      client.should_receive(:request).
        with('music', :q=>'Coltrane')
      client.music :q=>'Coltrane'
    end
    
  end
  
  context 'result object' do
    it 'should have a #context method which is a hash' do
      
    end
  end
  
  context :update do
    
    it 'should forward /update to #request("/update")' do
      client.should_receive(:request).
        with('update', {:wt=>:ruby}, "my xml message")
      client.update "my xml message"
    end
    
    it 'should forward #add calls to #update' do
      client.should_receive(:update) {|value,params|
        value.should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?><add><doc><field name=\"id\">1</field></doc></add>"
      }
      client.add(:id=>1)
    end

    it 'should forward #commit calls to #update' do
      client.should_receive(:update).
        with("<?xml version=\"1.0\" encoding=\"UTF-8\"?><commit/>")
      client.commit
    end

    it 'should forward #commit calls with options to #update' do
      opts = {:waitFlush => false, :waitSearcher => false, :expungeDeletes => true}
      client.should_receive(:update).
        with(opts)
      client.message.should_receive(:commit).
        and_return(opts)
      client.commit(opts)
    end
    
    it 'should forward #optimize calls to #update' do
      client.should_receive(:update).
        with("<?xml version=\"1.0\" encoding=\"UTF-8\"?><optimize/>")
      client.optimize
    end

    it 'should forward #optimize calls with options to #update' do
      opts = {:maxSegments => 5, :waitFlush => false}
      # when client.commit is called, it eventually calls update
      client.should_receive(:update).
        with(opts)
      client.message.should_receive(:optimize).
        and_return(opts)
      client.optimize(opts)
    end
    
    it 'should forward #rollback calls to #update' do
      client.should_receive(:update).
        with("<?xml version=\"1.0\" encoding=\"UTF-8\"?><rollback/>")
      client.rollback
    end
    
    it 'should forward #delete_by_id calls to #update' do
      client.should_receive(:update).
        with("<?xml version=\"1.0\" encoding=\"UTF-8\"?><delete><id>1</id></delete>")
      client.delete_by_id 1
    end
    
    it 'should forward #delete_by_query calls to #update' do
      client.should_receive(:update).
        with("<?xml version=\"1.0\" encoding=\"UTF-8\"?><delete><query>blah</query></delete>")
      client.delete_by_query 'blah'
    end
    
  end
  
  context :request do
    
    it 'should forward #request calls to the connection' do
      base_uri = URI.parse('http://localhost:8983/solr/').extend(RSolr::Uri)
      uri = base_uri.merge_with_params 'music', :q => 'Coltrane'
      context = {:request => {:uri => uri}, :response => {:body => '{}'}}
      client.connection.should_receive(:request).
        with('music', :q=>'Coltrane', :wt=>:ruby).
          # empty params so that Client doesn't try to evalulate to Ruby;
          #   -- this happens if the :wt equal :ruby
          and_return(context)
      client.should_receive(:adapt_response).
        with(context)
      client.request 'music', :q=>'Coltrane'
    end
    
  end

  context :adapt_response do
    
    it 'should not try to evaluate ruby when the :qt is not :ruby' do
      u = URI.parse('http://localhost:8983/solr').extend(RSolr::Uri)
      uri = u.merge_with_params 'select', {}
      body = '{:time=>"NOW"}'
      result = client.send(:adapt_response, {:request => {:uri => uri}, :response => {:body=>body}})
      result.should be_a(String)
      result.should == body
    end
    
    it 'should evaluate ruby responses when the :wt is :ruby' do
      u = URI.parse('http://localhost:8983/solr').extend(RSolr::Uri)
      uri = u.merge_with_params 'select', {:wt => :ruby}
      body = '{:time=>"NOW"}'
      result = client.send(:adapt_response, {:request => {:uri => uri}, :response => {:body=>body}})
      result.should be_a(Hash)
      result.should == {:time=>"NOW"}
    end
    
  end
  
end