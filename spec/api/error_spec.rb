require 'spec_helper'

RSpec.describe RSolr::Error do
  def generate_error_with_backtrace(request, response)
    raise RSolr::Error::Http.new request, response
  rescue RSolr::Error::Http => exception
    exception
  end
  let (:response_lines) { (1..15).to_a.map { |i| "line #{i}" } }
  let(:request)  { double :[] => "mocked" }
  let(:response_body) { response_lines.join("\n") }
  let(:response) {{
    :body   => response_body,
    :status => 400
  }}
  subject { generate_error_with_backtrace(request, response).to_s }

  context "when the response body is wrapped in a <pre> element" do
    let(:response_body) { "<pre>" + response_lines.join("\n") + "</pre>" }

    it "only shows the first eleven lines of the response" do
      expect(subject).to match(/line 1\n.+line 11\n\n/m)
    end

    context "when the response is one line long" do
      let(:response_body) { "<pre>failed</pre>" }
      it { should match(/Error: failed/) }
    end
  end

  context "when the response body is not wrapped in a <pre> element" do

    it "only shows the first eleven lines of the response" do
      expect(subject).to match(/line 1\n.+line 11\n\n/m)
    end

    context "when the response is one line long" do
      let(:response_body) { 'failed' }
      it { should match(/Error: failed/) }
    end
    context "when the response body contains a msg key" do
      let(:msg) { "'org.apache.solr.search.SyntaxError: Cannot parse \\':false\\': Encountered \" \":\" \": \"\" at line 1, column 0.'" }
      let(:response_body) { (response_lines << "'error'=>{'msg'=> #{msg}").join("\n") }
      it { should include msg }
    end

    context "when the response body is made of multi-byte chars and encoded by ASCII-8bit" do
      let (:response_lines) { (1..15).to_a.map { |i| "レスポンス #{i}".b } }

      it "encodes errorlogs by UTF-8" do
        expect(subject.encoding.to_s).to eq 'UTF-8'
      end
    end
  end

  context "when response is JSON" do
    let(:response) {{
      :body   => response_body,
      :status => 500,
      :headers => {
        "content-type" => "application/json;charset=utf-8"
      }

    }}

    context "and contains a msg key" do
      let(:msg) { "field 'description_text4_tesim' was indexed without offsets, cannot highlight" }
      let(:response_body) {<<~EOS
        {
          "responseHeader":{
            "status":500,
            "QTime":11,
            "params":{
              "q":"supercali",
              "hl":"true",
              "hl:fl":"description_text4_tesim",
              "hl.method":"unified",
              "hl.offsetSource":"postings"
            }
          },
          "response":{"numFound":0,"start":0,"maxScore":127.32743,"numFoundExact":true,"docs":[]},
          "facet_counts":{
            "facet_queries":{},
            "facet_fields":{}
          },
          "error":{
            "msg":"#{msg}",
            "trace":"java.lang.IllegalArgumentException: field 'description_text4_tesim' was indexed without offsets, cannot highlight\\n\\tat org.apache.lucene.search.uhighlight.FieldHighlighter.highlightOffsetsEnums(FieldHighlighter.java:149)\\n\\tat org.apache.lucene.search.uhighlight.FieldHighlighter.highlightFieldForDoc(FieldHighlighter.java:79)\\n\\tat org.apache.lucene.search.uhighlight.UnifiedHighlighter.highlightFieldsAsObjects(UnifiedHighlighter.java:641)\\n\\tat org.apache.lucene.search.uhighlight.UnifiedHighlighter.highlightFields(UnifiedHighlighter.java:510)\\n\\tat org.apache.solr.highlight.UnifiedSolrHighlighter.doHighlighting(UnifiedSolrHighlighter.java:149)\\n\\tat org.apache.solr.handler.component.HighlightComponent.process(HighlightComponent.java:172)\\n\\tat org.apache.solr.handler.component.SearchHandler.handleRequestBody(SearchHandler.java:331)\\n\\tat org.apache.solr.handler.RequestHandlerBase.handleRequest(RequestHandlerBase.java:214)\\n\\tat org.apache.solr.core.SolrCore.execute(SolrCore.java:2606)\\n\\tat org.apache.solr.servlet.HttpSolrCall.execute(HttpSolrCall.java:815)\\n\\tat org.apache.solr.servlet.HttpSolrCall.call(HttpSolrCall.java:588)\\n\\tat org.apache.solr.servlet.SolrDispatchFilter.doFilter(SolrDispatchFilter.java:415)\\n\\tat org.apache.solr.servlet.SolrDispatchFilter.doFilter(SolrDispatchFilter.java:345)\\n\\tat org.eclipse.jetty.servlet.ServletHandler$CachedChain.doFilter(ServletHandler.java:1596)\\n\\tat org.eclipse.jetty.servlet.ServletHandler.doHandle(ServletHandler.java:545)\\n\\tat org.eclipse.jetty.server.handler.ScopedHandler.handle(ScopedHandler.java:143)\\n\\tat org.eclipse.jetty.security.SecurityHandler.handle(SecurityHandler.java:590)\\n\\tat org.eclipse.jetty.server.handler.HandlerWrapper.handle(HandlerWrapper.java:127)\\n\\tat org.eclipse.jetty.server.handler.ScopedHandler.nextHandle(ScopedHandler.java:235)\\n\\tat org.eclipse.jetty.server.session.SessionHandler.doHandle(SessionHandler.java:1610)\\n\\tat org.eclipse.jetty.server.handler.ScopedHandler.nextHandle(ScopedHandler.java:233)\\n\\tat org.eclipse.jetty.server.handler.ContextHandler.doHandle(ContextHandler.java:1300)\\n\\tat org.eclipse.jetty.server.handler.ScopedHandler.nextScope(ScopedHandler.java:188)\\n\\tat org.eclipse.jetty.servlet.ServletHandler.doScope(ServletHandler.java:485)\\n\\tat org.eclipse.jetty.server.session.SessionHandler.doScope(SessionHandler.java:1580)\\n\\tat org.eclipse.jetty.server.handler.ScopedHandler.nextScope(ScopedHandler.java:186)\\n\\tat org.eclipse.jetty.server.handler.ContextHandler.doScope(ContextHandler.java:1215)\\n\\tat org.eclipse.jetty.server.handler.ScopedHandler.handle(ScopedHandler.java:141)\\n\\tat org.eclipse.jetty.server.handler.ContextHandlerCollection.handle(ContextHandlerCollection.java:221)\\n\\tat org.eclipse.jetty.server.handler.InetAccessHandler.handle(InetAccessHandler.java:177)\\n\\tat org.eclipse.jetty.server.handler.HandlerCollection.handle(HandlerCollection.java:146)\\n\\tat org.eclipse.jetty.server.handler.HandlerWrapper.handle(HandlerWrapper.java:127)\\n\\tat org.eclipse.jetty.rewrite.handler.RewriteHandler.handle(RewriteHandler.java:322)\\n\\tat org.eclipse.jetty.server.handler.HandlerWrapper.handle(HandlerWrapper.java:127)\\n\\tat org.eclipse.jetty.server.Server.handle(Server.java:500)\\n\\tat org.eclipse.jetty.server.HttpChannel.lambda$handle$1(HttpChannel.java:383)\\n\\tat org.eclipse.jetty.server.HttpChannel.dispatch(HttpChannel.java:547)\\n\\tat org.eclipse.jetty.server.HttpChannel.handle(HttpChannel.java:375)\\n\\tat org.eclipse.jetty.server.HttpConnection.onFillable(HttpConnection.java:273)\\n\\tat org.eclipse.jetty.io.AbstractConnection$ReadCallback.succeeded(AbstractConnection.java:311)\\n\\tat org.eclipse.jetty.io.FillInterest.fillable(FillInterest.java:103)\\n\\tat org.eclipse.jetty.io.ChannelEndPoint$2.run(ChannelEndPoint.java:117)\\n\\tat org.eclipse.jetty.util.thread.strategy.EatWhatYouKill.runTask(EatWhatYouKill.java:336)\\n\\tat org.eclipse.jetty.util.thread.strategy.EatWhatYouKill.doProduce(EatWhatYouKill.java:313)\\n\\tat org.eclipse.jetty.util.thread.strategy.EatWhatYouKill.tryProduce(EatWhatYouKill.java:171)\\n\\tat org.eclipse.jetty.util.thread.strategy.EatWhatYouKill.run(EatWhatYouKill.java:129)\\n\\tat org.eclipse.jetty.util.thread.ReservedThreadExecutor$ReservedThread.run(ReservedThreadExecutor.java:375)\\n\\tat org.eclipse.jetty.util.thread.QueuedThreadPool.runJob(QueuedThreadPool.java:806)\\n\\tat org.eclipse.jetty.util.thread.QueuedThreadPool$Runner.run(QueuedThreadPool.java:938)\\n\\tat java.base/java.lang.Thread.run(Thread.java:834)\\n",
            "code":500
          }
        }
        EOS
      }
      it {
        should include msg
      }
    end

    context "and does not contain a msg key" do
      let(:response_body) {<<~EOS
        {
          "responseHeader":{
            "status":500,
            "QTime":11,
            "params":{
              "q":"supercali",
              "hl":"true",
              "hl:fl":"description_text4_tesim",
              "hl.method":"unified",
              "hl.offsetSource":"postings"
            }
          },
          "response":{"numFound":0,"start":0,"maxScore":127.32743,"numFoundExact":true,"docs":[]},
          "facet_counts":{
            "facet_queries":{},
            "facet_fields":{}
          },
        }
        EOS
      }
      it "shows the first eleven lines of the response" do
        expect(subject).to include(response_body.split("\n")[0..10].join("\n"))
        expect(subject).not_to include(response_body.split("\n")[11])
      end
    end

    context "and is not parseable json" do
      let(:response_body) {<<~EOS
        one
        two
        three
        four
        five
        six
        seven
        eight
        nine
        ten
        eleven
        twelve
      EOS
      }
    end
    it "shows the first eleven lines of the response" do
      expect(subject).to include(response_body.split("\n")[0..10].join("\n"))
      expect(subject).not_to include(response_body.split("\n")[11])
    end
  end
end
