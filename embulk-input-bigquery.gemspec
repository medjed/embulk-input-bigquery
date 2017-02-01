# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'embulk/input/bigquery/version'

Gem::Specification.new do |spec|
  spec.name          = "embulk-input-bigquery"
  spec.version       = Embulk::Input::Bigquery::VERSION
  spec.authors       = ["Takeru Narita"]
  spec.email         = ["naritano77@gmail.com"]
  spec.description   = %q{embulk input plugin from bigquery.}
  spec.summary       = %q{Embulk input plugin from bigquery.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_dependency "google-cloud-bigquery", '~> 0.23'
end
