module VagrantPlugins
  module ServerSpec
    class Plugin < Vagrant.plugin('2')
      name 'serverspec'
      description <<-DESC
      This plugin executes a serverspec suite against a running Vagrant instance.
      DESC

      config(:serverspec) do
        require_relative 'config'
        Config
      end

      command(:serverspec) do
        require_relative 'command'
        Command
      end
    end
  end
end
