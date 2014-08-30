require 'rake/testtask'

# setup tests
Rake::TestTask.new do |t|
  puts "running tests"
  t.libs << "tests"
  t.test_files = FileList['tests/tc*.rb']
  t.verbose = true
end

# This is the default 'build' task. Append new items to it's task array as you create them.
task :build => [:test] do
  puts "Build completed!"
end

# set default task...
task :default => 'build'
