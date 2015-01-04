# vagrant-serverspec Windows readme

vagrant-serverspec is a [vagrant](http://vagrantup.com) plugin that implements
[serverspec](http://serverspec.org) as a provisioner.

It now supports Windows guests through WinRM.

## Installing

First, you'll need to install the plugin as described in README.md

## Example Usage

Next, configure the provisioner in your `Vagrantfile`.

```ruby
Vagrant.require_version ">= 1.6.2"

Vagrant.configure("2") do |config|
    config.vm.define "windows"
    config.vm.box = "windows"
    config.vm.communicator = "winrm"

    # Admin user name and password
    config.winrm.username = "vagrant"
    config.winrm.password = "vagrant"

    config.vm.guest = :windows
    config.vm.communicator = "winrm"
    config.windows.halt_timeout = 15

    config.vm.network :forwarded_port, guest: 3389, host: 3389, id: "rdp", auto_correct: true
    config.vm.network :forwarded_port, guest: 22, host: 2222, id: "ssh", auto_correct: true

  config.vm.provision :serverspec do |spec|
    spec.pattern = '*_spec.rb'
  end

end
```

You may want to override standart settings, file named `spec_helper.rb` usually used for that
For now possible examples is commented in this file

```ruby
#require 'serverspec'
#require 'pathname'
#require 'winrm'
#set :backend, :winrm
#set :os, :family => 'windows'

#user = 'vagrant'
#pass = 'vagrant'
#endpoint = "http://#{ENV['TARGET_HOST']}:5985/wsman"
#winrm = ::WinRM::WinRMWebService.new(endpoint, :ssl, :user => user, :pass => pass, :basic_auth_only => true)
#winrm.set_timeout 300 # 5 minutes max timeout for any operation
#Specinfra.configuration.winrm = winrm
```

Then you're ready to write your specs (some examples below).

```ruby
require_relative 'spec_helper'

describe command('Get-ExecutionPolicy') do
  its(:stdout) { should match /RemoteSigned/ }
  #its(:stderr) { should match /stderr/ }
  its(:exit_status) { should eq 0 }
end

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

#describe windows_feature('Web-Server') do
#  it{ should be_installed.by("powershell") }
#end

#describe port(80) do
#  it { should be_listening }
#end

#describe iis_website('Default Website') do
#  it{ should have_site_bindings(80) }
#end

#describe windows_registry_key(
#  'HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\advanced') do
#  it { should have_property_value('Hidden', :type_dword,'1') }
#end

#describe windows_feature('TelnetClient') do
#  it{ should be_installed.by("powershell") }
#end

#describe file('C:\Windows\system32\telnet.exe') do
#  it { should be_file }
#end
```
