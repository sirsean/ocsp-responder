$:.push File.expand_path("../lib", __FILE__)
require "r509/ocsp/responder/version"

spec = Gem::Specification.new do |s|
  s.name = 'r509-ocsp-responder'
  s.version = R509::Ocsp::Responder::VERSION
  s.platform = Gem::Platform::RUBY
  s.summary = "A (relatively) simple OCSP responder written to work with r509"
  s.description = 'An OCSP responder. What, you want more info?'
  s.add_dependency 'r509', '~>0.7'
  s.add_dependency 'redis'
  s.add_dependency 'r509-validity-redis'
  s.add_dependency 'sinatra'
  s.add_dependency 'dependo'
  s.add_development_dependency 'rspec', '>=2.11'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'syntax'
  s.add_development_dependency 'rack-test'
  s.add_development_dependency 'rcov' if RUBY_VERSION.split('.')[1].to_i == 8
  s.add_development_dependency 'simplecov' if RUBY_VERSION.split('.')[1].to_i == 9
  s.author = "Paul Kehrer"
  s.email = "paul.l.kehrer@gmail.com"
  s.homepage = "http://langui.sh"
  s.required_ruby_version = ">= 1.8.6"
  s.files = %w(README.md Rakefile) + Dir["{lib,script,spec,doc,cert_data}/**/*"]
  s.test_files= Dir.glob('test/*_spec.rb')
  s.require_path = "lib"
end

