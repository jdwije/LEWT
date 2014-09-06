require 'rubygems'
require 'rake/testtask'
require 'rubygems/package_task' 
require 'rdoc/task'

# setup
spec = Gem::Specification.new do |s|
  s.name        = 'lewt'
  s.version     = '0.5.7'
  s.date        = '2014-08-24'
  s.summary     = "Lazy Enterprise for hackers Without Time"
  s.description = "A dead simple command line tool and library for enterprise management. It can currently handle invoicing, expenses, reporting, and is highly extensible"
  s.authors     = ["Jason Wijegooneratne"]
  s.email       = 'code@jwije.com'
  s.files        = Dir.glob("{bin,lib}/**/*")
  s.executables = ["lewt"]
  s.homepage    = 'http://jwije.com/lewt'
  s.license       = 'MIT'
  # required gems
  s.add_dependency 'icalendar', '~> 2.0.0'
  s.add_dependency 'safe_yaml', '~> 1.0.0'
  s.add_dependency 'google_calendar', '~> 0.3.1'
  s.add_dependency 'liquid', '~> 2.5.0'
  s.add_dependency 'pdfkit', '~> 0.6.2'
  # example of how LEWT extensions can be made searchable.
  #  s.metadata = {
  #    'keyword' => 'lewt-extension'
  #  }
end

# setup tests
Rake::TestTask.new do |t|
  puts "running tests"
  t.libs << "tests"
  t.test_files = FileList['tests/tc*.rb']
  t.verbose = true
end


RDoc::Task.new :rdoc do |rdoc|
  rdoc.main = "README.rdoc"
  rdoc.rdoc_dir = "docs"
  rdoc.title = "LEWT"
  rdoc.rdoc_files.include("README.rdoc", "lib/**/*.rb")
end

# build gem and move to the ./dist directory
Gem::PackageTask.new(spec) do |pkg|
  pkg.need_zip = true
  pkg.need_tar = true
end

# This is the default 'build' task. Append new items to it's task array as you create them.
task :build => [:test, :rdoc] do
  puts "Build completed!"
end

# set default task...
task :default => 'build'
