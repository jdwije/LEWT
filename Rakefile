require 'rubygems'
require 'rake/testtask'
require 'rubygems/package_task' 
require 'rdoc/task'
require_relative "lib/lewt.rb"

# setup
spec = Gem::Specification.new do |s|
  s.name        = 'lewt'
  s.version     = LEWT::VERSION
  s.date        = Date.today.strftime("%Y-%m-%d")
  s.summary     = "Lazy Enterprise for hackers Without Time"
  s.description = "A simple command line tool and library for enterprise management. It can currently handle invoicing, expenses, reporting, and is very extensible."
  s.authors     = ["Jason Wijegooneratne"]
  s.email       = 'code@jwije.com'
  s.files        = [Dir.glob("{bin,lib,tests}/**/*"), 'README.md', 'LICENSE.md']
  s.executables = ["lewt"]
  s.homepage    = 'http://www.jwije.com/LEWT'
  s.license       = 'MIT'


  # required LEWT gems
  #  s.add_dependency 'safe_yaml', '~> 1.0.0'
  
  # required core extension gems
  # s.add_dependency 'icalendar', '~> 2.0.0'
  # s.add_dependency 'google_calendar', '~> 0.3.1'
  # s.add_dependency 'liquid', '~> 2.5.0'
  # s.add_dependency 'pdfkit', '~> 0.6.2'
end

# just some output helper methods
class CLOut

  def initialize
    @lineSymbol = "-"
    @paddingSymbol = " "
    @margin  = 2
    @padding = 4
  end

  def header (text)
    puts buildLine(text)
    puts buildMargin(false) + text.upcase + buildMargin(true)
    puts buildLine(text)
  end

  private

  def buildLine(text)
    line = String.new
    until line.length == text.length
      line += @lineSymbol
    end
    return (buildMargin(false) + line + buildMargin(true)).gsub!(@paddingSymbol, @lineSymbol)
  end


  def buildMargin( reverse )
    margin = String.new
    until margin.length == (@margin + @padding)
      if margin.length <= @margin
        margin += (reverse == false ? @lineSymbol : @paddingSymbol)
      else
        margin += (reverse == false ? @paddingSymbol : @lineSymbol)
      end
    end
    return margin
  end

end


# setup tests
Rake::TestTask.new do |t|
#  CLOut.new::header("running tests")
  t.libs << "tests"
  t.test_files = FileList['tests/tc*.rb']
  t.verbose = true
end


RDoc::Task.new :docs do |rdoc|
 # CLOut.new::header("Building documentation")
  rdoc.main = "README.md"
  rdoc.rdoc_dir = "docs"
  rdoc.title = "LEWT"
  rdoc.rdoc_files.include("README.md", "lib/**/*.rb")
end

# build gem and move to the ./dist directory
Gem::PackageTask.new(spec) do |pkg|
  #CLOut.new::header("Packaging")
  pkg.need_zip = false
  pkg.need_tar = false
end

# This is the default 'build' task. Append new items to it's task array as you create them.
task :build => [:test, :docs] do
  CLOut.new::header("Build Completed")
end

# set default task...
task :default => 'build'
