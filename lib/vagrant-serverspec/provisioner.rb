# This implementation executes rspec in-process. Because rspec effectively
# takes ownership of the global scope, executing rspec within a child process
# may be preferred.
module VagrantPlugins
  module ServerSpec
    class Provisioner < Vagrant.plugin('2', :provisioner)
      def initialize(machine, config)
        super
        @spec_files = config.spec_files
      end

      def provision
        if machine.config.vm.communicator == :winrm
          username = machine.config.winrm.username
          winrm_info = VagrantPlugins::CommunicatorWinRM::Helper.winrm_info(@machine)
          set :backend, :winrm
          set :os, :family => 'windows'
          user = machine.config.winrm.username
          pass = machine.config.winrm.password
          endpoint = "http://#{winrm_info[:host]}:#{winrm_info[:port]}/wsman"

          winrm = ::WinRM::WinRMWebService.new(endpoint, :ssl, :user => user, :pass => pass, :basic_auth_only => true)
          winrm.set_timeout machine.config.winrm.timeout
          Specinfra.configuration.winrm = winrm
        else
          set :backend, :ssh

          # Close the existing ssh connection if it exists.
          # Else, the existing connection will always used between different
          # serverspec provisions using the same process and can connect to a
          # previous host
          if Specinfra::Backend::Ssh.instance.get_config(:ssh)
            Specinfra::Backend::Ssh.instance.get_config(:ssh).close
            Specinfra::Backend::Ssh.instance.set_config(:ssh, nil)
          end

          if ENV['ASK_SUDO_PASSWORD']
            begin
              require 'highline/import'
            rescue LoadError
              fail "highline is not available. Try installing it."
            end
            set :sudo_password, ask("Enter sudo password: ") { |q| q.echo = false }
          else
            set :sudo_password, ENV['SUDO_PASSWORD']
          end

          host = machine.ssh_info[:host]
          options = Net::SSH::Config.for(host)

          options[:proxy]         = setup_provider_proxy if use_jump_provider?
          options[:user]          = machine.ssh_info[:username]
          options[:port]          = machine.ssh_info[:port]
          options[:keys]          = machine.ssh_info[:private_key_path]
          options[:password]      = machine.ssh_info[:password]
          options[:forward_agent] = machine.ssh_info[:private_key_path]

          set :host,        options[:host_name] || host
          set :ssh_options, options
        end

        # Always clean examples to not have duplicates between runs using the
        # same process
        RSpec.clear_examples

        status = RSpec::Core::Runner.run(@spec_files)

        raise Vagrant::Errors::ServerSpecFailed if status != 0
      end

      private

      def setup_provider_proxy
        ssh_info = machine.provider.host_vm.ssh_info
        host     = ssh_info[:host]
        port     = ssh_info[:port]
        username = ssh_info[:username]
        key_path = ssh_info[:private_key_path][0]

        proxy_options='-A -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no'
        Net::SSH::Proxy::Command.new("ssh #{proxy_options} -i #{key_path} -p #{port} #{username}@#{host} nc %h %p")
      end

      def use_jump_provider?
        jump_providers = [
          {
           name:      "DockerProvider",
           platforms: ["mac"]
          }
        ]
        current_provider_class = machine.provider.class.name.to_s

        jump_providers.any? do |jump_provider|
          if current_provider_class.include? jump_provider[:name]
            jump_provider[:platforms].any? do |platform|
              OS.send("#{platform}?")
            end
          end
        end
      end
    end
  end
end
