require 'serverspec'
require 'pathname'
require 'winrm'
require 'net/ssh'

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
          
          options[:user] = machine.ssh_info[:username]
          options[:port] = machine.ssh_info[:port]
          options[:keys] = machine.ssh_info[:private_key_path]
          options[:password] = machine.ssh_info[:password]
          options[:forward_agent] = machine.ssh_info[:private_key_path]

          set :host,        options[:host_name] || host
          set :ssh_options, options
        end

        status = RSpec::Core::Runner.run(@spec_files)

        raise Vagrant::Errors::ServerSpecFailed if status != 0
      end
    end
  end
end
