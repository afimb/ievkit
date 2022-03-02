# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ievkit/version'

Gem::Specification.new do |spec|
  spec.name          = 'ievkit'
  spec.version       = Ievkit::VERSION
  spec.authors       = ['Bruno Perles']
  spec.email         = ['bruno@atnos.com']

  spec.summary       = ''
  spec.description   = ''
  spec.homepage      = 'https://github.com/afimb/ievkit'
  spec.license       = 'CECILL-B'

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'figaro', '~> 1.2.0'
  spec.add_dependency 'faraday_middleware', '~> 0.14.0'
  spec.add_dependency 'rest-client', '~> 1.8.0'
  spec.add_dependency  'redis', '~>3.2'

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 11.1'
  spec.add_development_dependency 'rspec'
end
