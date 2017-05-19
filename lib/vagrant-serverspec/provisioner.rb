# This implementation executes rspec in-process. Because rspec effectively
# takes ownership of the global scope, executing rspec within a child process
# may be preferred.
module VagrantPlugins
  module ServerSpec
    class Provisioner < Vagrant.plugin('2', :provisioner)
      def initialize(machine, config)
        super
        @spec_files = config.spec_files
        @spec_pattern = config.spec_pattern
        @error_no_spec_files_found = config.error_no_spec_files_found
      end

      def provision
        if machine.config.vm.communicator == :winrm
          username = machine.config.winrm.username
          winrm_info = VagrantPlugins::CommunicatorWinRM::Helper.winrm_info(@machine)
          set :backend, :winrm
          set :os, :family => 'windows'

          opts = {
              endpoint: "http://#{winrm_info[:host]}:#{winrm_info[:port]}/wsman",
              user: machine.config.winrm.username,
              password: machine.config.winrm.password,
              transport: :ssl,
              operation_timeout: machine.config.winrm.timeout
          }
          winrm = ::WinRM::Connection.new(opts)
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

        @spec_files = Dir.glob(@spec_pattern)
        raise Vagrant::Errors::ServerSpecFilesNotFound if @spec_files.length == 0 and @error_no_spec_files_found

        if config.html_output_format
          require 'json'
          require 'rspec'
          require 'rspec_html_formatter'
          config_rspec = RSpec.configuration
          formatter = RspecHtmlFormatter.new(config_rspec.output_stream)

          # create reporter with RspecHtmlFormatter
          reporter =  RSpec::Core::Reporter.new(config_rspec)
          config_rspec.instance_variable_set(:@reporter, reporter)

          # api may not be stable, make sure lock down Rspec version
          loader = config_rspec.send(:formatter_loader)
          notifications = loader.send(:notifications_for, RspecHtmlFormatter)
          reporter.register_listener(formatter, *notifications)
	        
          status = RSpec::Core::Runner.run(@spec_files)
          raise Vagrant::Errors::ServerSpecFailedHtml if status != 0
        else
          status = RSpec::Core::Runner.run(@spec_files)
          raise Vagrant::Errors::ServerSpecFailed if status != 0
        end
        
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

