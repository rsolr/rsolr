require 'spec_helper'
describe "RSolr::Client" do

  module ClientHelper
    def node_urls
      @node_urls ||= ["http://localhost:9998/solr/", "http://localhost:9999/solr/"]
    end

    def client
      @client ||= RSolr.connect(:url => node_urls.dup, :read_timeout => 42, :open_timeout => 43)
    end

    def successful_response(httpv = '1.1', code = '200', msg = 'Ok')
      response = Net::HTTPOK.new(httpv, code, msg)
      response["content-type"] = "text/plain;charset=UTF-8"
      response.body = "{'responseHeader'=>{'status'=>0,'QTime'=>0,'params'=>{'q'=>'*:*'}},'response'=>{'numFound'=>0,'start'=>0,'docs'=>[]}}"
      response.instance_variable_set("@read", true)
      response
    end

    def request_context
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
  end

  context "initialize" do
    it "should accept whatevs and set it as the @connection" do
      expect(RSolr::Client.new(:whatevs).connection).to eq(:whatevs)
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

    it "should not modify stored URIs" do
      client.instance_variable_get("@available_uris").map(&:to_s).should eq node_urls

      expect { client.execute request_context }.to raise_error(Errno::ECONNREFUSED)

      client.instance_variable_get("@available_uris").map(&:to_s).should eq node_urls
    end

    context "in case of failures" do
      it "should try all available URIs and reset previously failed ones" do
        calls_index = -1
        called_uris = []
        new = Net::HTTP.method(:new)

        Net::HTTP.stub(:new) do |*args, &block|
          new.call(*args, &block).tap do |http|
            http_request = http.method(:request)

            http.stub(:request) do |request|
              calls_index += 1
              called_uris << "http://#{http.address}:#{http.port}/solr/"

              case calls_index
                when 0 # primary uri is http://localhost:9998/solr/
                  called_uris.last.should eq node_urls.first
                  http_request.call(request) # original http#request
                when 1 # primary uri is http://localhost:9999/solr/
                  called_uris.last.should eq node_urls.last
                  successful_response
                when 2 # primary uri is http://localhost:9999/solr/
                  called_uris.last.should eq node_urls.last
                  http_request.call(request) # original http#request
                when 3 # primary uri is http://localhost:9998/solr/
                  called_uris.last.should eq node_urls.first
                  successful_response
                else
                  http_request.call(request) # original http#request
              end
            end
          end
        end

        # Calls 0-1
        expect { client.execute request_context }.not_to raise_error
        client.instance_variable_get("@failed_uris").size.should eq 0
        client.instance_variable_get("@primary_uri").to_s.should eq node_urls.last
        called_uris.should eq node_urls

        # Calls 2-3
        expect { client.execute request_context }.not_to raise_error
        client.instance_variable_get("@failed_uris").size.should eq 0
        client.instance_variable_get("@primary_uri").to_s.should eq node_urls.first
        called_uris.should eq node_urls + node_urls.reverse

        # Calls 3+
        expect { client.execute request_context }.to raise_error(Errno::ECONNREFUSED)
        client.instance_variable_get("@failed_uris").size.should eq 0
        client.instance_variable_get("@primary_uri").to_s.should eq node_urls.first
        called_uris.should eq node_urls + node_urls.reverse + node_urls
      end
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
      body = '{:time=>"NOW"}'
      result = client.adapt_response({:params=>{}}, {:status => 200, :body => body, :headers => {}})
      expect(result).to eq(body)
    end

    it 'should evaluate ruby responses when the :wt is :ruby' do
      body = '{:time=>"NOW"}'
      result = client.adapt_response({:params=>{:wt=>:ruby}}, {:status => 200, :body => body, :headers => {}})
      expect(result).to eq({:time=>"NOW"})
    end

    it 'should evaluate json responses when the :wt is :json' do
      body = '{"time": "NOW"}'
      result = client.adapt_response({:params=>{:wt=>:json}}, {:status => 200, :body => body, :headers => {}})
      if defined? JSON
        expect(result).to eq({:time=>"NOW"})
      else
        # ruby 1.8 without the JSON gem
        expect(result).to eq('{"time": "NOW"}')
      end
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
    it 'should return a request context array' do
      result = client.build_request('select',
        :method => :post,
        :params => {:q=>'test', :fq=>[0,1]},
        :data => "data",
        :headers => {}
      )
      [/fq=0/, /fq=1/, /q=test/, /wt=ruby/].each do |pattern|
        expect(result[:query]).to match pattern
      end
      expect(result[:data]).to eq("data")
      expect(result[:headers]).to eq({})
    end

    it "should set the Content-Type header to application/x-www-form-urlencoded; charset=UTF-8 if a hash is passed in to the data arg" do
      result = client.build_request('select',
        :method => :post,
        :data => {:q=>'test', :fq=>[0,1]},
        :headers => {}
      )
      expect(result[:query]).to eq("wt=ruby")
      [/fq=0/, /fq=1/, /q=test/].each do |pattern|
        expect(result[:data]).to match pattern
      end
      expect(result[:data]).not_to match /wt=ruby/
      expect(result[:headers]).to eq({"Content-Type" => "application/x-www-form-urlencoded; charset=UTF-8"})
    end

  end

end
