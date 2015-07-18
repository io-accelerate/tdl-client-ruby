# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tdl/client/version'

Gem::Specification.new do |spec|
  spec.name          = 'tdl-client-ruby'
  spec.version       = TDL::VERSION
  spec.authors       = ['Julian Ghionoiu']
  spec.email         = ['iulian.ghionoiu@gmail.com']

  spec.summary       = %q{A client to connect to the central kata server.}
  spec.homepage      = 'https://github.com/julianghionoiu/tdl-client-ruby'
  spec.license       = 'GPL-3.0'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.10'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~>4.3.2'
  spec.add_development_dependency 'minitest-reporters', '~>0.14.24'
end
