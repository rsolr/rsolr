namespace :test do
  
  desc "Run basic tests"
  Rake::TestTask.new("units") { |t|
    t.pattern = 'test/**/*_test.rb'
    t.verbose = true
    t.warning = true
    t.libs << "test"
  }
  
end