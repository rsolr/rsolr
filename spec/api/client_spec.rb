require 'spec_helper'
describe "RSolr::Client" do

  module ClientHelper
    def client
      @client ||= (
        connection = RSolr::Connection.new
        RSolr::Client.new connection, :url => "http://localhost:9999/solr", :read_timeout => 42, :open_timeout=>43
      )
    end

    def client_with_proxy
      @client_with_proxy ||= (
        connection = RSolr::Connection.new
        RSolr::Client.new connection, :url => "http://localhost:9999/solr", :proxy => 'http://localhost:8080', :read_timeout => 42, :open_timeout=>43
      )
    end
  end

  context "initialize" do
    it "should accept whatevs and set it as the @connection" do
      expect(RSolr::Client.new(:whatevs).connection).to eq(:whatevs)
    end

    it "should use :update_path from options" do
      client = RSolr::Client.new(:whatevs, { update_path: 'update_test' })
      expect(client.update_path).to eql('update_test')
    end

    it "should use 'update' for update_path by default" do
      client = RSolr::Client.new(:whatevs)
      expect(client.update_path).to eql('update')
    end

    it "should use :proxy from options" do
      client = RSolr::Client.new(:whatevs, { proxy: 'http://my.proxy/' })
      expect(client.proxy.to_s).to eql('http://my.proxy/')
    end

    it "should use 'nil' for proxy by default" do
      client = RSolr::Client.new(:whatevs)
      expect(client.proxy).to be_nil
    end

    it "should use 'false' for proxy if passed 'false'" do
      client = RSolr::Client.new(:whatevs, { proxy: false })
      expect(client.proxy).to eq(false)
    end
  end

  context "send_and_receive" do
    include ClientHelper
    it "should forward these method calls the #connection object" do
      [:get, :post, :head].each do |meth|
        expect(client.connection).to receive(:execute).
          and_return({:status => 200, :body => "{}", :headers => {}})
        client.send_and_receive '', :method => meth, :params => {}, :data => nil, :headers => {}
      end
    end

    it "should be timeout aware" do
      [:get, :post, :head].each do |meth|
        expect(client.connection).to receive(:execute).with(client, hash_including(:read_timeout => 42, :open_timeout=>43))
        client.send_and_receive '', :method => meth, :params => {}, :data => nil, :headers => {}
      end
    end
  end

  context "execute" do
    include ClientHelper
    let :request_context do
      {
        :method => :post,
        :params => {},
        :data => nil,
        :headers => {},
        :path => '',
        :uri => client.base_uri,
        :retry_503 => 1
      }
    end
    it "should retry 503s if requested" do
      expect(client.connection).to receive(:execute).exactly(2).times.and_return(
        {:status => 503, :body => "{}", :headers => {'Retry-After' => 0}},
        {:status => 200, :body => "{}", :headers => {}}
      )
      client.execute request_context
    end
    it "should not retry a 503 if the retry-after is too large" do
      expect(client.connection).to receive(:execute).exactly(1).times.and_return(
        {:status => 503, :body => "{}", :headers => {'Retry-After' => 10}}
      )
      expect {
        Timeout.timeout(0.5) do
          client.execute({:retry_after_limit => 0}.merge(request_context))
        end
      }.to raise_error(RSolr::Error::Http)
    end
  end

  context "post" do
    include ClientHelper
    it "should pass the expected params to the connection's #execute method" do
      request_opts = {:data => "the data", :method=>:post, :headers => {"Content-Type" => "text/plain"}}
      expect(client.connection).to receive(:execute).
        with(client, hash_including(request_opts)).
        and_return(
          :body => "",
          :status => 200,
          :headers => {"Content-Type"=>"text/plain"}
        )
        client.post "update", request_opts
    end
  end

  context "xml" do
    include ClientHelper
    it "should return an instance of RSolr::Xml::Generator" do
      expect(client.xml).to be_a RSolr::Xml::Generator
    end
  end

  context "add" do
    include ClientHelper
    it "should send xml to the connection's #post method" do
      expect(client.connection).to receive(:execute).
        with(
          client, hash_including({
            :path => "update",
            :headers => {"Content-Type"=>"text/xml"},
            :method => :post,
            :data => "<xml/>"
          })
      ).
      and_return(
        :body => "",
        :status => 200,
        :headers => {"Content-Type"=>"text/xml"}
      )
      expect(client.xml).to receive(:add).
        with({:id=>1}, {:commitWith=>10}).
        and_return("<xml/>")
      client.add({:id=>1}, :add_attributes => {:commitWith=>10})
    end
  end

  context "update" do
    include ClientHelper
    it "should send data to the connection's #post method" do
      expect(client.connection).to receive(:execute).
        with(
          client, hash_including({
            :path => "update",
            :headers => {"Content-Type"=>"text/xml"},
            :method => :post,
            :data => "<optimize/>"
          })
      ).
      and_return(
        :body => "",
        :status => 200,
        :headers => {"Content-Type"=>"text/xml"}
      )
      client.update(:data => "<optimize/>")
    end

    it "should use #update_path" do
      expect(client).to receive(:post).with('update_test', any_args)
      expect(client).to receive(:update_path).and_return('update_test')
      client.update({})
    end

    it "should use path from opts" do
      expect(client).to receive(:post).with('update_opts', any_args)
      allow(client).to receive(:update_path).and_return('update_test')
      client.update({path: 'update_opts'})
    end
  end

  context "post based helper methods:" do
    include ClientHelper
    [:commit, :optimize, :rollback].each do |meth|
      it "should send a #{meth} message to the connection's #post method" do
        expect(client.connection).to receive(:execute).
          with(
            client, hash_including({
              :path => "update",
              :headers => {"Content-Type"=>"text/xml"},
              :method => :post,
              :data => "<?xml version=\"1.0\" encoding=\"UTF-8\"?><#{meth}/>"
            })
        ).
        and_return(
          :body => "",
          :status => 200,
          :headers => {"Content-Type"=>"text/xml"}
        )
        client.send meth
      end
    end
  end

  context "delete_by_id" do
    include ClientHelper
    it "should send data to the connection's #post method" do
      expect(client.connection).to receive(:execute).
        with(
          client, hash_including({
            :path => "update",
            :headers => {"Content-Type"=>"text/xml"},
            :method => :post,
            :data => "<?xml version=\"1.0\" encoding=\"UTF-8\"?><delete><id>1</id></delete>"
          })
      ).
      and_return(
        :body => "",
        :status => 200,
        :headers => {"Content-Type"=>"text/xml"}
      )
      client.delete_by_id 1
    end
  end

  context "delete_by_query" do
    include ClientHelper
    it "should send data to the connection's #post method" do
      expect(client.connection).to receive(:execute).
        with(
          client, hash_including({
            :path => "update",
            :headers => {"Content-Type"=>"text/xml"},
            :method => :post,
            :data => "<?xml version=\"1.0\" encoding=\"UTF-8\"?><delete><query fq=\"category:&quot;trash&quot;\"/></delete>"
          })
      ).
      and_return(
        :body => "",
        :status => 200,
        :headers => {"Content-Type"=>"text/xml"}
      )
      client.delete_by_query :fq => "category:\"trash\""
    end
  end

  context "adapt_response" do
    include ClientHelper
    it 'should not try to evaluate ruby when the :qt is not :ruby' do
      body = '{"time"=>"NOW"}'
      result = client.adapt_response({:params=>{}}, {:status => 200, :body => body, :headers => {}})
      expect(result).to eq(body)
    end

    it 'should evaluate ruby responses when the :wt is :ruby' do
      body = '{"time"=>"NOW"}'
      result = client.adapt_response({:params=>{:wt=>:ruby}}, {:status => 200, :body => body, :headers => {}})
      expect(result).to eq({"time"=>"NOW"})
    end

    it 'should evaluate json responses when the :wt is :json' do
      body = '{"time": "NOW"}'
      result = client.adapt_response({:params=>{:wt=>:json}}, {:status => 200, :body => body, :headers => {}})
      if defined? JSON
        expect(result).to eq({"time"=>"NOW"})
      else
        # ruby 1.8 without the JSON gem
        expect(result).to eq('{"time": "NOW"}')
      end
    end

    it 'should return a response for a head request' do
      result = client.adapt_response({:method=>:head,:params=>{}}, {:status => 200, :body => nil, :headers => {}})
      expect(result.response[:status]).to eq 200
    end

    it "ought raise a RSolr::Error::InvalidRubyResponse when the ruby is indeed frugged, or even fruggified" do
      expect {
        client.adapt_response({:params=>{:wt => :ruby}}, {:status => 200, :body => "<woops/>", :headers => {}})
      }.to raise_error RSolr::Error::InvalidRubyResponse
    end

  end

  context "indifferent access" do
    include ClientHelper
    it "should raise a RuntimeError if the #with_indifferent_access extension isn't loaded" do
      hide_const("HashWithIndifferentAccess")
      body = "{'foo'=>'bar'}"
      result = client.adapt_response({:params=>{:wt=>:ruby}}, {:status => 200, :body => body, :headers => {}})
      expect { result.with_indifferent_access }.to raise_error RuntimeError
    end

    it "should provide indifferent access" do
      require 'active_support/core_ext/hash/indifferent_access'
      body = "{'foo'=>'bar'}"
      result = client.adapt_response({:params=>{:wt=>:ruby}}, {:status => 200, :body => body, :headers => {}})
      indifferent_result = result.with_indifferent_access

      expect(result).to be_a(RSolr::Response)
      expect(result['foo']).to eq('bar')
      expect(result[:foo]).to be_nil

      expect(indifferent_result).to be_a(RSolr::Response)
      expect(indifferent_result['foo']).to eq('bar')
      expect(indifferent_result[:foo]).to eq('bar')
    end
  end

  context "build_request" do
    include ClientHelper
    let(:data) { 'data' }
    let(:params) { { q: 'test', fq: [0,1] } }
    let(:options) { { method: :post, params: params, data: data, headers: {} } }
    subject { client.build_request('select', options) }

    context "when params are symbols" do
      it 'should return a request context array' do
        [/fq=0/, /fq=1/, /q=test/, /wt=ruby/].each do |pattern|
          expect(subject[:query]).to match pattern
        end
        expect(subject[:data]).to eq("data")
        expect(subject[:headers]).to eq({})
      end
    end

    context "when params are strings" do
      let(:params) { { 'q' => 'test', 'wt' => 'json' } }
      it 'should return a request context array' do
        expect(subject[:query]).to eq 'q=test&wt=json'
        expect(subject[:data]).to eq("data")
        expect(subject[:headers]).to eq({})
      end
    end

    context "when a Hash is passed in as data" do
      let(:data) { { q: 'test', fq: [0,1] } }
      let(:options) { { method: :post, data: data, headers: {} } }

      it "sets the Content-Type header to application/x-www-form-urlencoded; charset=UTF-8" do
        expect(subject[:query]).to eq("wt=ruby")
        [/fq=0/, /fq=1/, /q=test/].each do |pattern|
          expect(subject[:data]).to match pattern
        end
        expect(subject[:data]).not_to match /wt=ruby/
        expect(subject[:headers]).to eq({"Content-Type" => "application/x-www-form-urlencoded; charset=UTF-8"})
      end
    end
   
    it "should properly handle proxy configuration" do
      result = client_with_proxy.build_request('select',
        :method => :post,
        :data => {:q=>'test', :fq=>[0,1]},
        :headers => {}
      )
      expect(result[:uri].to_s).to match /^http:\/\/localhost:9999\/solr\//
    end 
  end
end
