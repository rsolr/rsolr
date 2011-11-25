require 'rake'
require 'rake/testtask'
require 'bundler/gem_tasks'

require 'rubygems/package_task'

ENV['RUBYOPT'] = '-W1'
 
task :environment do
  require File.dirname(__FILE__) + '/lib/rsolr'
end
 
Dir['tasks/**/*.rake'].each { |t| load t }

task :default => ['spec:api']