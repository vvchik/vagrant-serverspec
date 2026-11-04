lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'vagrant-serverspec/version'

Gem::Specification.new do |gem|
  gem.name          = 'vagrant-serverspec'
  gem.homepage      = 'https://github.com/vvchik/vagrant-serverspec'
  gem.version       = VagrantPlugins::ServerSpec::VERSION
  gem.authors       = ['Jeremy Voorhis', 'Vladimir Babchynskyy', 'community contributors: https://github.com/vvchik/vagrant-serverspec/graphs/contributors']
  gem.email         = ['vvchik@gmail.com']
  gem.summary       = %q{A Vagrant plugin that executes serverspec}
  gem.description   = "vagrant-serverspec is a Vagrant plugin that integrates serverspec into your workflow."
  gem.license       = 'MIT'

  gem.metadata = {
    'homepage_uri'    => gem.homepage,
    'source_code_uri' => gem.homepage,
    'changelog_uri'   => "#{gem.homepage}/blob/master/CHANGELOG.md",
    'bug_tracker_uri' => "#{gem.homepage}/issues",
  }

  # Vagrant 2.4.x supports Ruby 3.0 - 3.4
  gem.required_ruby_version = '>= 3.0'

  gem.files         = `git ls-files -z`.split("\x0").reject { |f| f.start_with?('test/', '.github/') }
  gem.require_paths = ['lib']

  gem.add_runtime_dependency 'serverspec', '~> 2.43'

  # Keep winrm in the range accepted by Vagrant 2.4.x (>= 2.3.9, < 3.0)
  gem.add_runtime_dependency 'winrm', '~> 2.3', '>= 2.3.9'
  # HTML output uses RSpec's built-in html formatter (no extra gem needed).
  gem.add_runtime_dependency 'rspec_junit_formatter', '~> 0.6'

  gem.add_development_dependency 'rake', '~> 13.0'
  gem.add_development_dependency 'rspec', '~> 3.12'
end
