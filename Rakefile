require 'rubygems'
require 'rake/testtask'
require 'rubygems/package_task' 
require 'rdoc/task'

# setup
spec = Gem::Specification.new do |s|
  s.name        = 'lewt'
  s.version     = '0.5.10'
  s.date        = '2014-08-24'
  s.summary     = "Lazy Enterprise for hackers Without Time"
  s.description = "A dead simple command line tool and library for enterprise management. It can currently handle invoicing, expenses, reporting, and is highly extensible"
  s.authors     = ["Jason Wijegooneratne"]
  s.email       = 'code@jwije.com'
  s.files        = Dir.glob("{bin,lib}/**/*")
  s.executables = ["lewt"]
  s.homepage    = 'http://jwije.com/lewt'
  s.license       = 'MIT'
  

  # required LEWT gems
  s.add_dependency 'safe_yaml', '~> 1.0.0'
  
  # required core extension gems
  s.add_dependency 'icalendar', '~> 2.0.0'
  s.add_dependency 'google_calendar', '~> 0.3.1'
  s.add_dependency 'liquid', '~> 2.5.0'
  s.add_dependency 'pdfkit', '~> 0.6.2'
  s.add_dependency 'rinruby', '~> 2.0.3'
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


RDoc::Task.new :rdoc do |rdoc|
 # CLOut.new::header("Building documentation")
  rdoc.main = "README.rdoc"
  rdoc.rdoc_dir = "docs"
  rdoc.title = "LEWT"
  rdoc.rdoc_files.include("README.rdoc", "lib/**/*.rb")
end

# build gem and move to the ./dist directory
Gem::PackageTask.new(spec) do |pkg|
  #CLOut.new::header("Packaging")
  pkg.need_zip = true
  pkg.need_tar = true
end

# This is the default 'build' task. Append new items to it's task array as you create them.
task :build => [:test, :rdoc] do
  CLOut.new::header("Build Completed")
end

# set default task...
task :default => 'build'
