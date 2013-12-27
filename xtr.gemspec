# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'xtr/version'

Gem::Specification.new do |spec|
  spec.name          = 'xtr'
  spec.version       = Xtr::VERSION
  spec.authors       = ['Gosha Arinich']
  spec.email         = ['me@goshakkk.name']
  spec.description   = %q{A trading engine.}
  spec.summary       = %q{A trading engine}
  spec.homepage      = ''

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'algorithms', '~> 0.6'
  spec.add_runtime_dependency 'activesupport', '~> 4.0'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec', '~> 2.14'
end
