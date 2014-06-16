# setup
Gem::Specification.new do |s|
  s.name        = 'lewt'
  s.version     = '0.2.3'
  s.date        = '2014-06-16'
  s.summary     = "Lazy Enterprise for hackers Without Time"
  s.description = "A dead simple command line tool for managing enterprises. It can currently handle invoicing, expenses, reporting, and is very extensible"
  s.authors     = ["Jason Wijegooneratne"]
  s.email       = 'code@jwije.com'
  s.files       = ["lib/lewt.rb", "lib/extension"]
  s.executables = ["lewt"]
  s.homepage    = 'https://github.com/jdwije/lewt'
  s.license       = 'GPLv2'
  # required gems
  s.add_dependency 'icalendar', '~> 2.0.0'
  s.add_dependency 'safe_yaml', '~> 1.0.0'
  s.add_dependency 'google_calendar', '~> 0.3.1'
  s.add_dependency 'liquid', '~> 2.5.0'
end


