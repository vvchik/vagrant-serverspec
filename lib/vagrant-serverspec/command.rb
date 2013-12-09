
module VagrantPlugins
  module ServerSpec
    class Command < Vagrant.plugin('2', :command)

      def execute
        opts = OptionParser.new do |o|
          o.banner = 'Usage: vagrant serverspec [vm-name]'
        end

        vms = parse_options(opts)
        return unless vms

        @logger.debug "'serverspec' each target VM..."
        with_target_vms(vms) {|vm| run_on(vm) }
      end

      def run_on(vm)
        raise Vagrant::Errors::VMNotCreatedError if vm.state.id == :not_created
        raise Vagrant::Errors::VMInaccessible    if vm.state.id == :inaccessible
        raise Vagrant::Errors::VMNotRunningError if vm.state.id != :running

        vm.env.ui.info "[#{vm.name}] Running rspec..."

        spec_files = vm.config.serverspec.spec_files
        # if spec_files not specified, fallback to auto detection based on vm name.
        if spec_files.empty?
          # TODO should we have base_dir option? e.g "#{base_dir}/#{vm.name}/**/*_spec.rb"
          pattern = "**/#{vm.name.to_sym}/**/*_spec.rb"
          spec_files = Dir[pattern]
          vm.env.ui.info "[#{vm.name}] No spec pattern specified, use `#{pattern}` instead."
        end

        ::RSpec.configure do |spec|
          spec.exclusion_filter = vm.config.serverspec.exclusion_filter

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
