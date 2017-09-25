### Vagrant-Serverspec
***

[![Gem Version](https://badge.fury.io/rb/vagrant-serverspec.svg)](http://badge.fury.io/rb/vagrant-serverspec)

> **vagrant-serverspec is a [vagrant][vagrant] plugin that implements
> [serverspec][serverspec] as a provisioner.**

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
    # pattern for specfiles to search
    spec.pattern = '*_spec.rb'
    # disable error if no specfile was found ( usefull with dynamic specfile retrieving through another provisionner like Ansible Galaxy => specfiles can be saved into ansible role repository for example ). Default: true
    spec.error_no_spec_files = false
    # save result into html an report, saved into a 'rspec_html_reports' directory. Default: false
    spec.html_output = true
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

##Testing Docker Containers on OSX
On OSX the Vagrant docker provider runs a Boot2Docker VM, then launches your docker container on that VM. Vagrant does SSH Proxying to send the commands through that VM and have them reach the Docker Container. Vagrant serverspec handles this the same way by getting the container host VM infromation and proxying the commands to the machine through an SSH Proxy. This functionality was introduced in this [PR](https://github.com/jvoorhis/vagrant-serverspec/pull/17) 

## Additional informations

### SSH connections

SSH connection is closed before each provision run.
This is mandatory if the provision is applied to multiple vms in the same run,
else all runs will be applied to the first vm (See #22) due to an SSH
connection which already exists.
This functionality was introduced in this [PR](https://github.com/jvoorhis/vagrant-serverspec/pull/23)

### Server spec examples

RSpec examples are clear before each provision run.
This is mandatory if the provision is applied to multiple vms in the same run,
else each run replay examples of previous calls also.
This functionality was introduced in this [PR](https://github.com/jvoorhis/vagrant-serverspec/pull/23)

### In case of shared examples

If you use shared examples into your test suite, you need to use 'load' instead
of 'require', else errors can occurs (See #23 comments).

## Versioning

vagrant-serverspec aims to adhere to [Semantic Versioning 2.0.0][semver].

## Development

* Source hosted at [GitHub][repo]
* Report issues/questions/feature requests on [GitHub Issues][issues]

Pull requests are very welcome! Make sure your patches are well tested.
Ideally create a topic branch for every separate change you make. For
example:

1. Fork the repo
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Authors

Created and maintained by [Jeremy Voorhis][jvoorhis] (<jvoorhis@gmail.com>) and
a growing community of [contributors][contributors].

## License

MIT license (see [LICENSE][license])

[vagrant]: http://vagrantup.com
[serverspec]: http://serverspec.org
[semver]: http://semver.org/

[repo]: https://github.com/jvoorhis/vagrant-serverspec
[issues]: https://github.com/jvoorhis/vagrant-serverspec/issues

[jvoorhis]: https://github.com/jvoorhis
[contributors]: https://github.com/jvoorhis/vagrant-serverspec/graphs/contributors

[license]: https://github.com/jvoorhis/vagrant-serverspec/blob/master/LICENSE
