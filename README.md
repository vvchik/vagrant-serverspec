# vagrant-serverspec

vagrant-serverspec is a [vagrant](http://vagrantup.com) plugin that implements
[serverspec](http://serverspec.org) as a provisioner.

Issues and pull requests are welcome.

## Example Usage

First, you'll need to load the plugin and configure the provisioner.

```ruby
Vagrant.require_plugin('vagrant-serverspec')

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

You'll want to place some boilerplate into a file named `spec_helper.rb`

```ruby
require 'serverspec'
require 'pathname'
require 'net/ssh'

include SpecInfra::Helper::Ssh
include SpecInfra::Helper::DetectOS
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

## TODO

- [ ] Gem release
- [ ] Documentation
- [ ] Fork a child process to sandbox RSpec execution
- [ ] Integrate RSpec's error reporting with Vagrant's UI api
