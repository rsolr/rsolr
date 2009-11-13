require 'rubygems'
require 'rake/gempackagetask'

namespace :gem do  
  
  spec = eval(File.read(File.join(File.dirname(__FILE__), '..', 'rsolr.gemspec')))
  
  Rake::GemPackageTask.new(spec) do |pkg|
      pkg.need_tar = false
  end
  
  # Clean house
  desc 'Clean up tmp files.'
  task :clean do |t|
    FileUtils.rm_rf "doc"
    FileUtils.rm_rf "pkg"
  end
  
end