# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

#
VERSION = "0.30.1"


#~~~~~ Create gemspec

Gem::Specification.new do |spec|
  spec.name          = 'tdl-client-ruby'
  spec.version       = VERSION
  spec.metadata      = {}
  spec.authors       = ['Julian Ghionoiu']
  spec.email         = ['iulian.ghionoiu@gmail.com']

  spec.summary       = %q{A client to connect to the central kata server.}
  spec.description   = %q{A ruby client to connect to the kata server}
  spec.homepage      = 'https://github.com/julianghionoiu/tdl-client-ruby'
  spec.license       = 'GPL-3.0'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'stomp', '1.4.10'
  spec.add_runtime_dependency 'logging', '2.4.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake', '~> 13.3.0'
  spec.add_development_dependency 'minitest', '~> 5.25.5'
  spec.add_development_dependency 'minitest-reporters', '~> 1.7.1'
  spec.add_development_dependency 'json', '~> 2.12.2'
  spec.add_development_dependency 'cucumber', '~> 10.0.0'
  spec.add_development_dependency 'debase', '~> 0.2.9'
  spec.add_development_dependency 'ostruct', '~> 0.6.1'
  spec.add_development_dependency 'logger', '~> 1.7.0'
  spec.add_development_dependency 'syslog', '~> 0.3.0'
end
