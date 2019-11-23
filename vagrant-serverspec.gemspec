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

  gem.add_runtime_dependency 'serverspec', '~> 2.30', '>= 2.30'

  #add only dependencies for winrm without nokogiri
  gem.add_runtime_dependency 'winrm', '~> 2.1', '>= 2.1'
  gem.add_runtime_dependency 'os', '~> 0.9.6'
  gem.add_runtime_dependency 'rspec_html_formatter', '~> 0.3', '>= 0.3.1'
  gem.add_runtime_dependency 'rspec_junit_formatter', '~> 0.4'
  gem.add_runtime_dependency 'activesupport', '~> 5.2.3', '>= 5.2'

  gem.add_development_dependency 'bundler', '~> 1.17.3', '>= 1.17'
  gem.add_development_dependency 'rake', '~> 10.3', '>= 10.3.2'
end
