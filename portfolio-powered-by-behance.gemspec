# coding: utf-8

Gem::Specification.new do |s|
  s.name        = 'portfolio-powered-by-behance'
  s.version     = '0.0.2'
  s.summary     = 'Portfolio powered by Behance'
  s.description = "Portfolio powered by Behance and cached with redis."
  s.authors     = 'Dávid Vass'
  s.email       = 'me@davidvass.sk'
  s.files       =  Dir['lib/   *.rb']
  s.license     = 'MIT'

  s.rubyforge_project = 'portfolio-powered-by-behance'

  ['rest-client', 'redis', 'slim'].each do |d|
    s.add_dependency d
  end
end
