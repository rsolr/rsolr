require 'helper'

describe RSolr::Connection::Base do
  
  context 'the initialize method' do
    
    it 'should require one argument' do
      lambda{RSolr::Connection::Base.new}.should raise_error(ArgumentError)
    end
    
  end
  
  before(:each) do
    @adapter = mock('RSolr::Connection::HTTP')
    @connection = RSolr::Connection::Base.new(@adapter)
  end
  
  context '#map_params method' do
    it 'should merge :wt=>:ruby to the incoming params' do
      result = @connection.send(:map_params, {})
      result[:wt].should == :ruby
    end
    it 'should not overwrite an existing :wt param' do
      result = @connection.send(:map_params, {:wt=>'xml'})
      result[:wt].should == 'xml'
    end
  end
  
  context '#adapt_response method' do
    it 'should evaluate the :body value if the :wt param IS :ruby' do
      response_from_adapter = {:body=>'{}', :params=>{:wt=>:ruby}}
      result = @connection.send(:adapt_response, response_from_adapter)
      result.should be_a(Hash)
    end
    it 'should not evaluate the :body value if the :wt is NOT :ruby' do
      response_from_adapter = {:body=>'</xml>', :params=>{:wt=>:xml}}
      result = @connection.send(:adapt_response, response_from_adapter)
      result.should be_a(String)
    end
    it 'should return an object that will respond_to?(:adapter_response)' do
      response_from_adapter = {:body=>'</xml>', :params=>{:wt=>:xml}}
      result = @connection.send(:adapt_response, response_from_adapter)
      result.should respond_to(:adapter_response)
    end
    it 'should return the original adapter response from #adapter_response method' do
      response_from_adapter = {:body=>'</xml>', :params=>{:wt=>:xml}}
      result = @connection.send(:adapt_response, response_from_adapter)
      result.adapter_response.should == response_from_adapter
    end
  end
  
  it 'should have an adapter' do
    @connection.adapter.should == @adapter
  end
  
  it 'should send requests to the adapter' do
    params = {:wt=>:ruby, :q=>'test'}
    expected_return = {:params=>params, :body=>'{}'}
    @adapter.should_receive(:request).with(
      '/documents',
      params,
      nil
    ).once.and_return(expected_return)
    @connection.request('/documents', :q=>'test')
  end
  
  context '#select method' do
    
    it 'should set the solr request path to /select' do
      params = {:wt=>:ruby, :q=>'test'}
      expected_return = {:params=>params, :body=>'{}'}
      @adapter.should_receive(:request).with(
        '/select',
        params,
        nil
      ).once.and_return(expected_return)
      @connection.select(:q=>'test')
    end
    
    it 'should add a :qt=>:ruby to the params, then pass the params to the adapter' do
      input_params = {:q=>'test', :fq=>'filter:one', :fq=>'documents'}
      expected_modified_params = input_params.merge({:wt=>:ruby})
      expected_return = {:body=>'{}', :params=>expected_modified_params}
      @adapter.should_receive(:request).with(
        '/select',
        hash_including(expected_modified_params),
        nil
      ).once.and_return(expected_return)
      @connection.select(input_params)
    end
    
    it 'should return a hash' do
      @adapter.should_receive(:request).and_return(
        {:body=>'{}', :params=>{:wt=>:ruby}}
      )
      @connection.select(:q=>'test').should be_a(Hash)
    end
    
  end
  
  context '#update method' do
    
    it 'should set the solr request path to /update' do
      expected_params = {:name=>'test', :wt=>:ruby}
      @adapter.should_receive(:request).with(
        '/update',
        hash_including(expected_params),
        '</optimize>'
      ).once.and_return(
        {:body=>'{}', :params=>expected_params}
      )
      @connection.update('</optimize>', :name=>'test')
    end
    
    it 'should accept a solr params hash' do
      @adapter.should_receive(:request).with(
        '/update',
        hash_including(:xyz=>123, :wt=>:ruby),
        '</optimize>'
      ).once.and_return(
        {:body=>'{}', :params=>{:xyz=>123, :wt=>:ruby}}
      )
      @connection.update('</optimize>', :xyz=>123)
    end
    
  end
  
  context '#request method' do
    
    it 'should send the request path to the adapter' do
      @adapter.should_receive(:request).with(
        '/documents',
        hash_including(:q=>'test', :wt=>:ruby),
        nil
      ).once.and_return({:body=>'{}', :params=>{:wt=>:ruby, :q=>'test'}})
      @connection.request('/documents', :q=>'test')
    end
    
    it 'should return an object will respond_to :adapter_response' do
      @adapter.should_receive(:request).with(
        '/select',
        hash_including(:q=>'test', :wt=>:ruby),
        nil
      ).once.and_return({:body=>'{}', :params=>{:q=>'test', :wt=>:ruby}})
      response = @connection.select(:q=>'test')
      response.should respond_to(:adapter_response)
    end
    
  end
  
end