#-*- ruby -*-

require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "clucumber"
    gem.summary = %Q{Test drive your Common Lisp application from Cucumber}
    gem.description = %Q{A cucumber extension that lets you write your step definitions in Common Lisp. 
      Set internal state in your Hunchentoot web app or your library, and use the full power of Cucumber and its other extensions.}
    gem.email = "asf@boinkor.net"
    gem.homepage = "http://github.com/antifuchs/clucumber"
    gem.authors = ["Andreas Fuchs"]
    gem.add_development_dependency "aruba", ">= 0"
    gem.add_development_dependency "cucumber", ">= 0"
    
    gem.files = "lib/**/*.rb", "lib/**/*.lisp", "lib/**/*.asd"
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: gem install jeweler"
end

begin
  require 'cucumber/rake/task'
  [:test, :cucumber, :features].each do |the_task|
    Cucumber::Rake::Task.new(the_task)
    task the_task => :check_dependencies
  end
rescue LoadError
  task :test do
    abort "Cucumber is not available. In order to run features, you must: sudo gem install cucumber"
  end
end

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "clucumber #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
