lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-serverspec/version'

Gem::Specification.new do |gem|
  gem.name          = 'vagrant-serverspec'
  gem.version       = VagrantPlugins::ServerSpec::VERSION
  gem.authors       = ['Jeremy Voorhis']
  gem.email         = ['jvoorhis@gmail.com']
  gem.description   = %q{A Vagrant provisioner that executes serverspec}
  gem.summary       = gem.description
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency 'serverspec', '~> 1.0'

  gem.add_development_dependency 'bundler', '~> 1.3'
  gem.add_development_dependency 'rake'
end
