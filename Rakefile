require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/gempackagetask'

ENV['RUBYOPT'] = '-W1'
 
task :environment do
  require File.dirname(__FILE__) + '/lib/rsolr'
end
 
Dir['tasks/**/*.rake'].each { |t| load t }

task :default => ['spec:api']