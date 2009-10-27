gem 'rspec', '~>1.2.8'

require 'spec'
require 'spec/rake/spectask'

desc 'run all specs'
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = ['spec/spec_helper.rb']
  t.spec_files << FileList[File.join(File.dirname(__FILE__), '..', 'spec', '**', '*_spec.rb')]
  t.spec_opts = ['--color']
end

namespace :spec do
  
  desc 'run api specs (mock out Solr dependency)'
  Spec::Rake::SpecTask.new('api') do |t|
    t.spec_files = ['spec/spec_helper.rb']
    t.spec_files << FileList[File.join(File.dirname(__FILE__), '..', 'spec', 'api', '**', '*_spec.rb')]
    t.spec_opts = ['--color']
  end
  
end