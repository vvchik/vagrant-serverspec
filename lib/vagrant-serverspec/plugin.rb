require 'rspec/core'
require 'serverspec'
require 'pathname'
require 'winrm'
require 'net/ssh'

 module VagrantPlugins
  module ServerSpec
    class Plugin < Vagrant.plugin('2')
      name 'serverspec'
      description <<-DESC
      This plugin executes a serverspec suite against a running Vagrant instance.
      DESC

      config(:serverspec, :provisioner) do
        require_relative 'config'
        Config
      end

      provisioner(:serverspec) do
        require_relative 'provisioner'
        Provisioner
      end
    end
  end
end
