gem 'rspec', '~>1.2.8'

require 'spec'
require 'spec/rake/spectask'

namespace :spec do
  
  desc 'run api specs (mock out Solr dependency)'
  Spec::Rake::SpecTask.new(:api) do |t|
    
    unless defined?(JRUBY_VERSION)
      t.rcov_opts = ['--exclude', 'spec', '--exclude', 'lib/xout.rb']
      t.rcov = true
    end
    
    t.spec_files = [File.join('spec', 'spec_helper.rb')]
    t.spec_files += FileList[File.join('spec', 'api', '**', '*_spec.rb')]
    
    if defined? JRUBY_VERSION
      t.spec_files += FileList[File.join('spec', 'api', '**', '*_spec_jruby.rb')]
    else
      t.rcov_opts += ['--exclude', 'lib/rsolr/connection/direct']
    end
    
    t.verbose = true
    t.spec_opts = ['--color']
  end
  
end