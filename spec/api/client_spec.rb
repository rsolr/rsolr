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
  
  context 'pagination' do
    
    it 'should respond to #paginate' do
      client = new_client
      client.should respond_to(:paginate)
    end
    
    it 'should successfully paginate' do
      client = new_client
      client.should_receive(:request).
        with({:rows=>10, :start=>0, :q=>'coltrane'}).
          and_return({
            'response'=>{
              'docs'=>[],
              'start' => 0,
              'numFound' => 100
            },
            'responseHeader' => {
              'params' => {
                'rows' => 10
              }
            }
          })
      response = client.paginate 1, 10, :q=>'coltrane'
      docs = response['response']['docs']
      docs.current_page.should == 1
      docs.total_pages.should == 100/10
      docs.previous_page.should == 1
      docs.next_page.should == 2
      docs.has_next?.should == true
      docs.has_previous?.should == false
      docs.per_page.should == 10
      docs.start.should == 0
      docs.total.should == 100
    end
    
    it 'should successfully paginate using a set handler path' do
      client = new_client
      client.should_receive(:request).
        with('/music', {:rows=>10, :start=>0, :q=>"the tuss"}).
          and_return({
            'response'=>{
              'docs'=>[],
              'start' => 0,
              'numFound' => 100
            },
            'responseHeader' => {
              'params' => {
                'rows' => 10
              }
            }
          })
      response = client.paginate 1, 10, '/music', :q=>'the tuss'
      docs = response['response']['docs']
      docs.current_page.should == 1
      docs.total_pages.should == 100/10
      docs.previous_page.should == 1
      docs.next_page.should == 2
      docs.has_next?.should == true
      docs.has_previous?.should == false
      docs.per_page.should == 10
      docs.start.should == 0
      docs.total.should == 100
    end
    
    it 'should successfully paginate using a dynamic (method_missing) handler path' do
      client = new_client
      client.should_receive(:request).
        with('/music', {:rows=>10, :start=>0}).
          and_return({
            'response'=>{
              'docs'=>[],
              'start' => 0,
              'numFound' => 100
            },
            'responseHeader' => {
              'params' => {
                'rows' => 10
              }
            }
          })
      response = client.paginate_music 1, 10
      docs = response['response']['docs']
      docs.current_page.should == 1
      docs.total_pages.should == 100/10
      docs.previous_page.should == 1
      docs.next_page.should == 2
      docs.has_next?.should == true
      docs.has_previous?.should == false
      docs.per_page.should == 10
      docs.start.should == 0
      docs.total.should == 100
    end
    
  end
  
end