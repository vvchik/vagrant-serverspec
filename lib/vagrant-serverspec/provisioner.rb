require 'serverspec'

# This implementation executes rspec in-process. Because rspec effectively
# takes ownership of the global scope, executing rspec within a child process
# may be preferred.
module VagrantPlugins
  module ServerSpec
    class Provisioner < Vagrant.plugin('2', :provisioner)
      def initialize(machine, config)
        super

        ssh_info = machine.ssh_info
        @spec_files = config.spec_files

        RSpec.configure do |spec|
          spec.before :all do
            ssh_host                 = ssh_info[:host]
            ssh_username             = ssh_info[:username]
            ssh_opts                 = Net::SSH::Config.for(ssh_info[:host])
            ssh_opts[:port]          = ssh_info[:port]
            ssh_opts[:forward_agent] = ssh_info[:forward_agent]
            ssh_opts[:keys]          = ssh_info[:private_key_path]

            spec.ssh = Net::SSH.start(ssh_host, ssh_username, ssh_opts)
          end

          spec.after :all do
            spec.ssh.close if spec.ssh && !spec.ssh.closed?
          end
        end
      end

      def provision
        status = RSpec::Core::Runner.run(@spec_files)

        raise Vagrant::Errors::ServerSpecFailed if status != 0
      end
    end
  end
end
