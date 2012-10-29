# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'devise-authy/version'

Gem::Specification.new do |s|
  s.name     = 'devise-authy'
  s.version  = '0.0.1'
  s.authors  = ['Johanna Mantilla Duque']
  s.email    = ['johanna1431@gmail.com']
  s.summary  = 'Authy strategy for Devise'
  s.homepage = 'https://github.com/senekis/devise-authy'

  s.files = Dir["{app,config,lib}/**/*"] + %w[LICENSE.txt README.rdoc]
  # s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_runtime_dependency 'rails', "~> 3.2.8"
  s.add_runtime_dependency 'authy', '~> 0.0.7'
  s.add_runtime_dependency 'devise', '~> 2.1.2'
  s.add_runtime_dependency 'orm_adapter'

  s.add_development_dependency 'rspec'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'jeweler'
end
