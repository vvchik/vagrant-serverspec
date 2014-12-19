lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-serverspec/version'

Gem::Specification.new do |gem|
  gem.name          = 'vagrant-serverspec'
  gem.homepage      = 'https://github.com/jvoorhis/vagrant-serverspec'
  gem.version       = VagrantPlugins::ServerSpec::VERSION
  gem.authors       = ['Jeremy Voorhis']
  gem.email         = ['jvoorhis@gmail.com']
  gem.summary       = %q{A Vagrant plugin that executes serverspec}
  gem.description   = "vagrant-serverspec is a Vagrant plugin that integrates serverspec into your workflow."
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_runtime_dependency 'serverspec', '~> 1.16', '>= 1.16.0'
  gem.add_runtime_dependency 'rspec-its', '>= 1.0.1', '< 1.1.0'
  gem.add_development_dependency 'bundler', '~> 1.6', '>= 1.6.2'
  gem.add_development_dependency 'rake', '~> 10.3', '>= 10.3.2'
end
