
### v 2.0.0 Nov 04, 2026

Major version: the plugin now targets Vagrant 2.4.x / Ruby 3.x. Closes all open
Dependabot alerts (bundler 1.x, activesupport 5.2).

**Breaking**
* Requires Ruby >= 3.0 (Vagrant 2.4.x supports Ruby 3.0 - 3.4).
* `html_output` now uses RSpec's built-in HTML formatter. The report is still
  written to `rspec_html_reports/overview.html`, but it looks different from the
  old `rspec_html_formatter` report. That gem is unmaintained and crashes on
  Ruby >= 3.2 (`File.exists?` was removed), so it is dropped together with its
  `activesupport` dependency.
* Dropped unused runtime dependencies: `activesupport`, `os`.
* Dropped `bundler ~> 1.17` development dependency.

**Dependencies**
* serverspec `~> 2.43`
* winrm `~> 2.3, >= 2.3.9` (range accepted by Vagrant 2.4.x)
* rspec_junit_formatter `~> 0.6`
* rake `~> 13.0` (development)
* Gemfile: Vagrant is installed from rubygems.org (`~> 2.4`) instead of `git://github.com/hashicorp/vagrant`

**Fixes**
* Docker provider: the SSH ProxyCommand through the host VM was never enabled
  because the provider class name was compared with `'DockerProvider'` instead
  of `VagrantPlugins::DockerProvider::Provider`.

**Tooling**
* Added an RSpec unit test suite (`spec/`) and a GitHub Actions workflow that
  runs it on Ruby 3.1 - 3.4, builds the gem, installs it into Vagrant and
  validates the sample Vagrantfile.
* Gem publish workflow now runs on `v*` tags, uses `ruby/setup-ruby`
  (`actions/setup-ruby` is archived) and publishes through RubyGems trusted
  publishing (OIDC) instead of a stored API key.

### v 1.5.3 (unreleased)
* fix: SSH Proxy command with Docker is only used when the host VM is enabled

### v 1.5.2 Oct 02, 2020
* Add 'exclude_pattern' option

### v 1.5.1 Mar 02, 2020
* Security, update rake build dependency version to 12.3.3

### v 1.5.0 Nov 25, 2019
* Add a new junit formatter

### v 1.4.0 Nov 1, 2019 (not released)
* Fix vagrant-serverspec dependencies to work with Vagrant 2.2.6

### v 1.3.0 Sep 24, 2017
* Add new options 'error_no_spec_files' to avoid error when no rspec conf files was found

### v 1.2.0 Mar 27, 2017
* Provide compatibility with vagrant 1.9.2
* Updated .gemspec to the recommended winrm version 2.x
* Updated WinRM::Connection instead of WinRM::WebService
* Updated `WINDOWS_README.md`
