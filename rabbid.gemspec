# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rabbid/version'

def add_gem_to spec, g, *reqs
	spec.add_runtime_dependency g, *reqs
end

Gem::Specification.new do |spec|
	spec.name          = "rabbid"
	spec.version       = Rabbid::VERSION
	spec.authors       = ["George Rogers"]
	spec.email         = ["grogers385@gmail.com"]
	spec.summary       = %q{Write a short summary. Required.}
	spec.description   = %q{Write a longer description. Optional.}
	spec.homepage      = ""
	spec.license       = "MIT"

	spec.files         = `git ls-files -z`.split("\x0")
	spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
	spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
	spec.require_paths = ["lib"]

	spec.add_development_dependency "bundler", "~> 1.5"
	spec.add_development_dependency "rake"

	add_gem_to spec, 'sinatra', '~> 1.4.0'
	add_gem_to spec, 'async_sinatra'
	add_gem_to spec, 'slim', '~> 2.0.2'
	add_gem_to spec, 'thin'
	add_gem_to spec, 'bunny', '~> 1.1.8'
end
