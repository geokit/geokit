# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'geokit/version'

Gem::Specification.new do |spec|
  spec.name          = 'geokit'
  spec.version       = Geokit::VERSION
  spec.authors       = ['Michael Noack', 'James Cox', 'Andre Lewis', 'Bill Eisenhauer']
  spec.email         = ['michael+geokit@noack.com.au']
  spec.description   = 'Geokit provides geocoding and distance calculation in an easy-to-use API'
  spec.summary       = 'Geokit: encoding and distance calculation gem'
  spec.homepage      = 'http://github.com/geokit/geokit'
  spec.license       = 'MIT'

  spec.rdoc_options = ['--main', 'README.markdown']
  spec.extra_rdoc_files = ['README.markdown']

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 1.9.3'
  spec.add_development_dependency 'bundler', '>= 1.0'
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency 'mocha'
  spec.add_development_dependency 'pre-commit'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'simplecov-rcov'
  spec.add_development_dependency 'test-unit'
  spec.add_development_dependency 'typhoeus' # used in net_adapter
  spec.add_development_dependency 'vcr'
  # webmock 2 not yet compatible out of the box with VCR
  spec.add_development_dependency 'webmock', '< 2' # used in vcr
end
