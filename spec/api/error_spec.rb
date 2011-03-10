require 'spec_helper'
describe "RSolr::Error" do
  def generate_error_with_backtrace(request, response)
    raise RSolr::Error::Http.new request, response
  rescue RSolr::Error::Http => exception
    exception
  end

  context "when the response body is wrapped in a <pre> element" do
    before do
      response_lines = (1..15).to_a.map { |i| "line #{i}" }

      @request  = mock :[] => "mocked"
      @response = {
        :body   => "<pre>" + response_lines.join("\n") + "</pre>",
        :status => 400
      }
    end

    it "only shows the first eleven lines of the response" do
      error = generate_error_with_backtrace @request, @response
      error.to_s.should match(/line 1\n.+line 11\n\n/m)
    end

    it "shows only one line when the response is one line long" do
      @response[:body] = "<pre>failed</pre>"

      error = generate_error_with_backtrace @request, @response
      error.to_s.should match(/Error: failed/)
    end
  end

  context "when the response body is not wrapped in a <pre> element" do
    before do
      response_lines = (1..15).to_a.map { |i| "line #{i}" }

      @request  = mock :[] => "mocked"
      @response = {
        :body   => response_lines.join("\n"),
        :status => 400
      }
    end

    it "only shows the first eleven lines of the response" do
      error = generate_error_with_backtrace @request, @response
      error.to_s.should match(/line 1\n.+line 11\n\n/m)
    end

    it "shows only one line when the response is one line long" do
      @response[:body] = "failed"

      error = generate_error_with_backtrace @request, @response
      error.to_s.should match(/Error: failed/)
    end
  end
end
