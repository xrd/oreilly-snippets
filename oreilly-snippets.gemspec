# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'oreilly/snippets/version'

Gem::Specification.new do |spec|
  spec.name          = "oreilly-snippets"
  spec.version       = Oreilly::Snippets::VERSION
  spec.authors       = ["Chris Dawson"]
  spec.email         = ["xrdawson@gmail.com"]
  spec.description   = %q{Use O'Reilly style snippets inside your markup (asciidoc or markdown) files}
  spec.summary       = %q{See the README}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
