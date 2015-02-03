# vagrant-serverspec

vagrant-serverspec is a [vagrant](http://vagrantup.com) plugin that implements
[serverspec](http://serverspec.org) as a provisioner.

Issues and pull requests are welcome.

## Installing
### Standard way
First, install the plugin.

```shell
$ vagrant plugin install vagrant-serverspec
```
### In case of fork usage
in case of fork usage you need to build it first
```shell
gem build vagrant-serverspec.gemspec
```
(on windows you may use embedded vagrant ruby for that)
```shell
C:\HashiCorp\Vagrant\embedded\bin\gem.bat build vagrant-serverspec.gemspec
```
after that install plugin from filesystem
```shell
vagrant plugin install ./vagrant-serverspec-0.5.0.gem
```

## Example Usage

Next, configure the provisioner in your `Vagrantfile`.

```ruby
Vagrant.configure('2') do |config|
  config.vm.box = 'precise64'
  config.vm.box_url = 'http://cloud-images.ubuntu.com/precise/current/precise-server-cloudimg-vagrant-amd64-disk1.box'

  config.vm.provision :shell, inline: <<-EOF
    sudo ufw allow 22
    yes | sudo ufw enable
  EOF

  config.vm.provision :serverspec do |spec|
    spec.pattern = '*_spec.rb'
  end
end
```

You may want to override standard settings; a file named `spec_helper.rb` is usually used for that. Here are some examples of possible overrides.

```ruby
# Disable sudo
# set :disable_sudo, true

# Set environment variables
# set :env, :LANG => 'C', :LC_MESSAGES => 'C' 

# Set PATH
# set :path, '/sbin:/usr/local/sbin:$PATH'
```

Then you're ready to write your specs.

```ruby
require_relative 'spec_helper'

describe package('ufw') do
  it { should be_installed }
end

describe service('ufw') do
  it { should be_enabled }
  it { should be_running }
end

describe port(22) do
  it { should be_listening }
end
```
