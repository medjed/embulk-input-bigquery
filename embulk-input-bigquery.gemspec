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

  # TODO
  # signet 0.12.0, google-api-client 0.33.0
  # google-cloud-env 1.3.0 and google-cloud-core 1.4.0 "require >= Ruby 2.4.
  # Embulk 0.9 use JRuby 9.1.X.Y and It compatible Ruby 2.3.
  # So, Force install signet < 0.12, google-api-client < 0.33.0
  # google-cloud-env 1.3.0 and google-cloud-core 1.4.0
  spec.add_dependency 'signet', '~> 0.7', '< 0.12.0'
  spec.add_dependency 'google-api-client','< 0.33.0'
  spec.add_dependency 'google-cloud-env','< 1.3.0'
  spec.add_dependency 'google-cloud-core','< 1.4.0'
  spec.add_dependency 'google-cloud-bigquery', ['>= 1.2', '< 1.12']
  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end
