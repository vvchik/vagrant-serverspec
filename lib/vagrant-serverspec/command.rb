require 'rspec'

module VagrantPlugins
  module ServerSpec
    class Command < Vagrant.plugin('2', :command)

      def execute
        options = {}
        options[:provision_enabled] = true
        options[:destroy_enabled]   = true
        options[:ci_report]         = false

        opts = OptionParser.new do |o|
          o.banner = 'Usage: vagrant serverspec [vm-name] [options] [-h]'
          o.separator ''

          o.on('--[no-]provision', 'Enable or disable provisioning before the spec runs.') do |provision|
            options[:provision_enabled] = provision
          end

          o.on('--[no-]destroy', 'Enable or disable destroy after the spec runs.') do |destroy|
            options[:destroy_enabled] = destroy
          end

          o.on('--ci-report', 'Enable CI Report.') do |ci_report|
            options[:ci_report_enabled] = ci_report
          end

        end

        vms = parse_options(opts)
        return unless vms

        @logger.debug "'serverspec' each target VM..."
        with_target_vms(vms) do |vm|
          vm.env.cli('up', vm.name) unless vm.state.id == :running
          vm.env.cli('provision', vm.name) if options[:provision_enabled]

          vm.env.ui.info "[#{vm.name}] Running rspec..."

          begin
            run_on(vm, options)
          rescue => e
            vm.env.ui.warn "[#{vm.name}] spec failed: #{[e.message, e.backtrace].flatten.join("\n")}"
          ensure
            if options[:destroy_enabled]
              vm.env.cli('destroy', '--force', vm.name)
            else
              vm.env.cli('halt', vm.name)
            end
          end
          vm.env.ui.info "[#{vm.name}] rspec done."
        end
      end

      def run_on(vm, options)
        raise Vagrant::Errors::VMNotCreatedError if vm.state.id == :not_created
        raise Vagrant::Errors::VMInaccessible    if vm.state.id == :inaccessible
        raise Vagrant::Errors::VMNotRunningError if vm.state.id != :running

        spec_files = vm.config.serverspec.spec_files
        # if spec_files not specified, fallback to auto detection based on vm name.
        if spec_files.empty?
          # TODO should we have base_dir option? e.g "#{base_dir}/#{vm.name}/**/*_spec.rb"
          pattern = "**/#{vm.name.to_sym}/**/*_spec.rb"
          spec_files = Dir[pattern]
          vm.env.ui.info "[#{vm.name}] No spec pattern specified, use `#{pattern}` instead."
        end

        ::RSpec.configure do |spec|
          if spec.exclusion_filter = vm.config.serverspec.exclusion_filter
            vm.env.ui.info "[#{vm.name}] Set exclusion filter: #{spec.exclusion_filter.inspect}."
          end
          if options[:ci_report_enabled]
            require 'ci/reporter/rspec'
            spec.formatter = CI::Reporter::RSpec
            vm.env.ui.info "[#{vm.name}] Use ci_report formatter."
          end

          spec.before :all do
            ssh_host                 = vm.ssh_info[:host]
            ssh_username             = vm.ssh_info[:username]
            ssh_opts                 = Net::SSH::Config.for(vm.ssh_info[:host])
            ssh_opts[:port]          = vm.ssh_info[:port]
            ssh_opts[:forward_agent] = vm.ssh_info[:forward_agent]
            ssh_opts[:keys]          = vm.ssh_info[:private_key_path]

            spec.ssh = Net::SSH.start(ssh_host, ssh_username, ssh_opts)
          end

          spec.after :all do
            spec.ssh.close if spec.ssh && !spec.ssh.closed?
          end
        end

        ::RSpec::Core::Runner.run(spec_files)
      end

    end
  end
end
