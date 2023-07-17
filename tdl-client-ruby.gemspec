# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tdl/previous_version'

#~~~~~~ Compute version

# Add increment to Version class
class ComparableVersion < Gem::Version
  def increment
    segments = self.segments.dup
    segments[-1] = segments[-1].succ

    self.class.new segments.join('.')
  end
end

# Get Spec version from Git
spec_folder = File.expand_path('../features/spec',__FILE__).to_s
major_minor_version = `git --git-dir #{spec_folder}/.git describe --all | cut -d '/' -f 2 | tr -d 'v'`.strip

# Compute next version
previous_version = ComparableVersion.new(TDL::PREVIOUS_VERSION)
new_spec_version = ComparableVersion.new(major_minor_version+'.1')
if new_spec_version > previous_version
  current_version = new_spec_version
else
  current_version = previous_version.increment
end
# puts "previous_version = #{previous_version}"
# puts "current_version = #{current_version}"

VERSION = "#{current_version}"


#~~~~~ Create gemspec

Gem::Specification.new do |spec|
  spec.name          = 'tdl-client-ruby'
  spec.version       = VERSION
  spec.metadata      = { 'previous_version' => TDL::PREVIOUS_VERSION }
  spec.authors       = ['Julian Ghionoiu']
  spec.email         = ['iulian.ghionoiu@gmail.com']

  spec.summary       = %q{A client to connect to the central kata server.}
  spec.description   = %q{A ruby client to connect to the kata server}
  spec.homepage      = 'https://github.com/julianghionoiu/tdl-client-ruby'
  spec.license       = 'GPL-3.0'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'stomp', '1.4.10'
  spec.add_runtime_dependency 'logging', '2.3.1'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake', '~> 13.0.6'
  spec.add_development_dependency 'minitest', '~> 5.18.1'
  spec.add_development_dependency 'minitest-reporters', '~> 1.6.0'
  spec.add_development_dependency 'json', '~> 2.6.3'
  spec.add_development_dependency 'cucumber', '~> 8.0.0'
  spec.add_development_dependency 'debase', '~> 3.0.0.beta.6'
end
