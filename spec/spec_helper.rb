require File.expand_path('../../lib/rsolr', __FILE__)

def with_proxy_env(proxy)
  old_proxy = ENV['http_proxy']
  ENV['http_proxy'] = proxy
  begin
    yield
  ensure
    ENV['http_proxy'] = old_proxy
  end
end
