require 'serverspec'

# This implementation executes rspec in-process. Because rspec effectively
# takes ownership of the global scope, executing rspec within a child process
# may be preferred.
module VagrantPlugins
  module ServerSpec
    class Provisioner < Vagrant.plugin('2', :provisioner)
      def initialize(machine, config)
        super(machine, config)

        @spec_files = config.spec_files

        unless machine.config.vm.communicator == :winrm
          # SSH
          RSpec.configure do |spec|
            spec.before :all do
              ssh_host                 = machine.ssh_info[:host]
              ssh_username             = machine.ssh_info[:username]
              ssh_opts                 = Net::SSH::Config.for(machine.ssh_info[:host])
              ssh_opts[:port]          = machine.ssh_info[:port]
              ssh_opts[:forward_agent] = machine.ssh_info[:forward_agent]
              ssh_opts[:keys]          = machine.ssh_info[:private_key_path]

              spec.ssh = Net::SSH.start(ssh_host, ssh_username, ssh_opts)
            end

            spec.after :all do
              spec.ssh.close if spec.ssh && !spec.ssh.closed?
            end
          end
        end
      end

      def provision
        if machine.config.vm.communicator == :winrm
          # WinRM
          username = machine.config.winrm.username
          winrm_info = VagrantPlugins::CommunicatorWinRM::Helper.winrm_info(@machine)

          RSpec.configure do |c|
            user = machine.config.winrm.username
            pass = machine.config.winrm.password
            endpoint = "http://#{winrm_info[:host]}:#{winrm_info[:port]}/wsman"

            c.winrm = ::WinRM::WinRMWebService.new(endpoint, :ssl, :user => user, :pass => pass, :basic_auth_only => true)
            c.winrm.set_timeout machine.config.winrm.timeout
          end
        end

        RSpec::Core::Runner.run(@spec_files)
      end
    end
  end
end
