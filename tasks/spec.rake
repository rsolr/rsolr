require "rubygems"
require 'rspec'
require 'rspec/core/rake_task'

namespace :spec do
  
  namespace :ruby do
    desc 'run api specs through the Ruby implementations'
    task :api do
      puts "Ruby 1.8.7"
      puts `rake spec:api`
      puts "Ruby 1.9"
      puts `rake1.9 spec:api`
      puts "JRuby"
      puts `jruby -S rake spec:api`
    end
  end
  
  desc 'run api specs (mock out Solr dependency)'
  RSpec::Core::RakeTask.new(:api) do |t|
    
    t.pattern = [File.join('spec', 'spec_helper.rb')]
    t.pattern += FileList[File.join('spec', 'api', '**', '*_spec.rb')]
    
    t.verbose = true
    t.rspec_opts = ['--color']
  end
  
  desc 'run integration specs'
  RSpec::Core::RakeTask.new(:integration) do |t|
    
    t.pattern = [File.join('spec', 'spec_helper.rb')]
    t.pattern += FileList[File.join('spec', 'integration', '**', '*_spec.rb')]
    
    t.verbose = true
    t.rspec_opts = ['--color']
  end
  
end