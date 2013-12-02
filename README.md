# vagrant-serverspec

vagrant-serverspec is a [vagrant](http://vagrantup.com) plugin that implements
[serverspec](http://serverspec.org) as a provisioner.

Issues and pull requests are welcome.

## Example Vagrantfile

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

## TODO

* Gem release
* Documentation
* Fork a child process to sandbox RSpec execution
* Integrate RSpec's error reporting with Vagrant's UI api
