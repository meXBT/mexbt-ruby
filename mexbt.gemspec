# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mexbt/version'

Gem::Specification.new do |spec|
  spec.name          = "mexbt"
  spec.version       = Mexbt::VERSION
  spec.authors       = ["williamcoates"]
  spec.email         = ["william@mexbt.com"]
  spec.summary       = %q{meXBT API client}
  spec.homepage      = "https://github.com/meXBT/mexbt-ruby"
  spec.license       = "MIT"
  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
