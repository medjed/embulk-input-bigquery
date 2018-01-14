# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'embulk/input/bigquery/version'

Gem::Specification.new do |spec|
  spec.name          = 'embulk-input-bigquery'
  spec.version       = Embulk::Input::Bigquery::VERSION
  spec.authors       = ['potato2003', 'Naotoshi Seo', 'Takeru Narita']
  spec.email         = ['potato2003@gmail.com', 'sonots@gmail.com', 'naritano77@gmail.com']
  spec.description   = 'embulk input plugin from bigquery.'
  spec.summary       = 'Embulk input plugin from bigquery.'
  spec.homepage      = 'https://github.com/medjed/embulk-input-bigquery'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'google-cloud-bigquery', '~> 0.24'
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end
