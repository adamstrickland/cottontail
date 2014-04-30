# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cottontail/version'

Gem::Specification.new do |spec|
  spec.name          = "cottontail"
  spec.version       = Cottontail::VERSION
  spec.authors       = ["Adam Strickland"]
  spec.email         = ["adam.strickland@gmail.com"]
  spec.summary       = %q{A convenence library for pub/sub objects using RabbitMQ and Ruby}
  # spec.description   = %q{TODO: Write a longer description. Optional.}
  spec.homepage      = "http://github.com/wearemolecule/cottontail"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "database_cleaner"
  spec.add_development_dependency "pry"
  spec.add_development_dependency "pry-nav"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "activesupport"
  spec.add_development_dependency "verbs"

  spec.add_dependency "bunny"
end
