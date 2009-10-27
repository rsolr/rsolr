gem 'rspec', '~>1.2.8'

require 'spec'
require 'spec/rake/spectask'

namespace :spec do
  
  desc 'run api specs (mock out Solr dependency)'
  Spec::Rake::SpecTask.new('api') do |t|
    t.spec_files = [File.join('spec', 'spec_helper.rb')]
    t.spec_files += FileList[File.join('spec', 'api', '**', '*_spec.rb')]
    puts t.spec_files.inspect
    t.spec_opts = ['--color']
  end
  
end