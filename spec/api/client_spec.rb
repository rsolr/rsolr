describe RSolr::Client do
  
  let(:client){ RSolr::Client.new('') }
  
  context :method_missing do
    
    it 'a non-existent method should be forwarded to #method_missing and then to #request' do
      client.should_receive(:request).
        with('/music', :q=>'Coltrane')
      client.music :q=>'Coltrane'
    end
    
  end
  
  context :update do
    
    it 'should forward /update to #request("/update")' do
      client.should_receive(:request)#.
      #  with('/update', {:wt=>:ruby}, "my xml message")
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
      # when client.commit is called, it eventually calls update
      client.should_receive(:update).
        with(opts)
      # client.message is calls to create the xml
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
      # client.message is calls to create the xml
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
      client.connection.should_receive(:request).
        with('/music', :q=>'Coltrane', :wt=>:ruby).
          # empty params so that Client doesn't try to evalulate to Ruby;
          #   -- this happens if the :wt equal :ruby
          and_return(:params=>{})
      client.request '/music', :q=>'Coltrane'
    end

  end

  context :ping do
    it 'should forwad #ping? calls to the connection' do
      client.connection.should_receive(:request).
        with('/admin/ping', :wt => :ruby ).
        and_return( :params => { :wt => :ruby },
                    :status_code => 200,
                    :body => "{'responseHeader'=>{'status'=>0,'QTime'=>44,'params'=>{'echoParams'=>'all','echoParams'=>'all','q'=>'solrpingquery','qt'=>'standard','wt'=>'ruby'}},'status'=>'OK'}" )
      client.ping?
    end

    it 'should raise an error if the ping service is not available' do
      client.connection.should_receive(:request).
        with('/admin/ping', :wt => :ruby ).
        # the first part of the what the message would really be
        and_raise( RSolr::RequestError.new("Solr Response: pingQuery_not_configured_consider_registering_PingRequestHandler_with_the_name_adminping_instead__") )
        lambda { client.ping? }.should raise_error( RSolr::RequestError )
    end
    
  end
  
  context :adapt_response do
    
    it 'should not try to evaluate ruby when the :qt is not :ruby' do
      body = '{:time=>"NOW"}'
      result = client.send(:adapt_response, {:body=>body, :params=>{}})
      result.should be_a(String)
      result.should == body
    end
    
    it 'should evaluate ruby responses when the :wt is :ruby' do
      body = '{:time=>"NOW"}'
      result = client.send(:adapt_response, {:body=>body, :params=>{:wt=>:ruby}})
      result.should be_a(Hash)
      result.should == {:time=>"NOW"}
    end
    
  end
  
end
