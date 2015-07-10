
Gem::Specification.new do |s|
  s.name         = 'jansson'
  s.version      = '0.0.1'
  s.date         = '2015-07-09'
  s.summary      = 'jansson'
  s.description  = 'A Ruby JSON library based on FFI bindings for libjansson.'
  s.authors      = ['Joe McIlvain']
  s.email        = 'joe.eli.mac@gmail.com'
  
  s.files        = Dir['{lib}/**/*.rb', 'bin/*', 'LICENSE', '*.md']
  s.extensions   = ['ext/jansson/Rakefile']
  
  s.require_path = 'lib'
  s.homepage     = 'https://github.com/jemc/ruby-jansson'
  s.licenses     = 'MIT'
  
  s.add_dependency 'ffi', '~> 1.9', '>= 1.9.8'
  
  s.add_development_dependency 'bundler',   '~>  1.6'
  s.add_development_dependency 'rake',      '~> 10.3'
  s.add_development_dependency 'pry',       '~>  0.9'
  s.add_development_dependency 'rspec',     '~>  3.0'
  s.add_development_dependency 'rspec-its', '~>  1.0'
  s.add_development_dependency 'fivemat',   '~>  1.3'
end
