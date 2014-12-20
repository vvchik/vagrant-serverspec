# vagrant-serverspec Windows support

vagrant-serverspec is a [vagrant](http://vagrantup.com) plugin that implements
[serverspec](http://serverspec.org) as a provisioner.
It also supports Windows guests through WinRM.

## Example Usage

First, you'll need to install the plugin.

```shell
vagrant plugin install vagrant-serverspec
```

Then create a Windows box.

```ruby
Vagrant.configure('2') do |config|
  config.vm.box = 'ferventcoder/win7pro-x64-nocm-lite'

  config.vm.provision :serverspec do |spec|
    spec.pattern = '*_spec.rb'
  end
end
```

You'll want to place some boilerplate into a file named `spec_helper.rb`

```ruby
require 'serverspec'
require 'pathname'
require 'winrm'

include Serverspec::Helper::WinRM
include Serverspec::Helper::Windows
```

Then you're ready to write your specs.

```ruby
require_relative 'spec_helper'

describe user('vagrant') do
  it { should exist }
  it { should belong_to_group('Administrators')}
end

describe port(5985) do
  it { should be_listening }
end

describe file('c:/windows') do
  it { should be_directory }
  it { should_not be_writable.by('Everyone') }
end
```

See more details at [serverspec WINDOWS_SUPPORT.md](https://github.com/serverspec/serverspec/blob/093cd1a0ca61325e1d54578118f8b30523aae2c1/WINDOWS_SUPPORT.md).
