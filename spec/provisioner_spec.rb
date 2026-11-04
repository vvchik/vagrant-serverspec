require 'spec_helper'
require 'tmpdir'

describe VagrantPlugins::ServerSpec::Provisioner do
  let(:ssh_info) do
    {
      host: '192.0.2.10',
      port: 2222,
      username: 'vagrant',
      private_key_path: ['/tmp/insecure_private_key'],
      password: nil,
    }
  end

  let(:provider_config) { double('provider_config', force_host_vm: false) }
  let(:provider)        { double('provider', config: provider_config) }
  let(:vm_config)       { double('vm_config', communicator: :ssh) }
  let(:machine_config)  { double('machine_config', vm: vm_config) }
  let(:machine) do
    double('machine', config: machine_config, ssh_info: ssh_info, provider: provider)
  end

  let(:config) do
    VagrantPlugins::ServerSpec::Config.new.tap do |c|
      c.pattern = 'spec/*_spec.rb'
      c.finalize!
    end
  end

  let(:rspec_config) { double('rspec_config') }
  let(:runner_status) { 0 }

  subject(:provisioner) { described_class.new(machine, config) }

  around do |example|
    Dir.mktmpdir('vagrant-serverspec') do |dir|
      Dir.chdir(dir) do
        FileUtils.mkdir_p('spec')
        File.write('spec/one_spec.rb', '')
        File.write('spec/two_spec.rb', '')
        File.write('spec/exclude_me_spec.rb', '')
        example.run
      end
    end
  end

  before do
    # Never let the provisioner touch the RSpec runtime that executes this suite.
    allow(RSpec).to receive(:clear_examples)
    allow(RSpec).to receive(:configure).and_yield(rspec_config)
    allow(RSpec::Core::Runner).to receive(:run).and_return(runner_status)
    allow(rspec_config).to receive(:add_formatter)

    # Start from a clean Specinfra ssh connection state.
    Specinfra::Backend::Ssh.instance.set_config(:ssh, nil)
  end

  def provider_class(name)
    klass = Class.new
    allow(klass).to receive(:name).and_return(name)
    klass
  end

  describe 'ssh backend' do
    before { allow(provider).to receive(:class).and_return(provider_class('VagrantPlugins::ProviderVirtualBox::Provider')) }

    it 'configures specinfra from machine.ssh_info and runs the spec files' do
      provisioner.provision

      expect(Specinfra.configuration.backend).to eq(:ssh)
      expect(Specinfra.configuration.host).to eq('192.0.2.10')

      opts = Specinfra.configuration.ssh_options
      expect(opts[:user]).to eq('vagrant')
      expect(opts[:port]).to eq(2222)
      expect(opts[:keys]).to eq(['/tmp/insecure_private_key'])
      expect(opts).not_to have_key(:proxy)

      expect(RSpec::Core::Runner).to have_received(:run)
        .with(a_collection_containing_exactly('spec/one_spec.rb', 'spec/two_spec.rb', 'spec/exclude_me_spec.rb'))
    end

    it 'honours exclude_pattern' do
      config.exclude_pattern = 'spec/exclude_*_spec.rb'
      config.finalize!

      provisioner.provision

      expect(RSpec::Core::Runner).to have_received(:run)
        .with(a_collection_containing_exactly('spec/one_spec.rb', 'spec/two_spec.rb'))
    end

    it 'clears the examples before running' do
      provisioner.provision
      expect(RSpec).to have_received(:clear_examples)
    end

    it 'closes a stale specinfra ssh connection' do
      stale = double('ssh', close: nil)
      Specinfra::Backend::Ssh.instance.set_config(:ssh, stale)

      provisioner.provision

      expect(stale).to have_received(:close)
      expect(Specinfra::Backend::Ssh.instance.get_config(:ssh)).to be_nil
    end

    it 'uses SUDO_PASSWORD from the environment' do
      begin
        ENV['SUDO_PASSWORD'] = 's3cret'
        provisioner.provision
        expect(Specinfra.configuration.sudo_password).to eq('s3cret')
      ensure
        ENV.delete('SUDO_PASSWORD')
        set :sudo_password, nil
      end
    end

    context 'when the suite fails' do
      let(:runner_status) { 1 }

      it 'raises ServerSpecFailed' do
        expect { provisioner.provision }.to raise_error(Vagrant::Errors::ServerSpecFailed)
      end

      it 'raises ServerSpecFailedHtml with html output' do
        config.html_output = true
        expect { provisioner.provision }.to raise_error(Vagrant::Errors::ServerSpecFailedHtml)
      end

      it 'raises ServerSpecFailedJunit with junit output' do
        config.junit_output = true
        expect { provisioner.provision }.to raise_error(Vagrant::Errors::ServerSpecFailedJunit)
      end

      it 'raises ServerSpecFailedHtmlJunit with both outputs' do
        config.html_output = true
        config.junit_output = true
        expect { provisioner.provision }.to raise_error(Vagrant::Errors::ServerSpecFailedHtmlJunit)
      end
    end

    context 'formatters' do
      it 'adds the built-in html formatter writing to rspec_html_reports/overview.html' do
        config.html_output = true
        provisioner.provision
        expect(rspec_config).to have_received(:add_formatter).with('html', 'rspec_html_reports/overview.html')
        expect(File).to be_directory('rspec_html_reports')
      end

      it 'adds the junit formatter with the default file name' do
        config.junit_output = true
        provisioner.provision
        expect(rspec_config).to have_received(:add_formatter).with('RSpecJUnitFormatter', 'rspec.xml')
      end

      it 'adds the junit formatter with a custom file name' do
        config.junit_output = true
        config.junit_output_file = 'reports/out.xml'
        provisioner.provision
        expect(rspec_config).to have_received(:add_formatter).with('RSpecJUnitFormatter', 'reports/out.xml')
      end
    end

    context 'no spec files' do
      it 'raises ServerSpecFilesNotFound when the pattern matches nothing' do
        config.pattern = 'spec/nothing_here_*.rb'
        config.finalize!
        expect { provisioner.provision }.to raise_error(Vagrant::Errors::ServerSpecFilesNotFound)
      end

      it 'does not raise when error_no_spec_files is false' do
        config.pattern = 'spec/nothing_here_*.rb'
        config.error_no_spec_files = false
        config.finalize!
        expect { provisioner.provision }.not_to raise_error
        expect(RSpec::Core::Runner).to have_received(:run).with([])
      end
    end
  end

  describe 'docker provider with host VM' do
    let(:host_vm_ssh_info) do
      { host: '10.0.0.5', port: 22, username: 'docker', private_key_path: ['/tmp/host_vm_key'] }
    end
    let(:host_vm)  { double('host_vm', ssh_info: host_vm_ssh_info) }

    before do
      allow(provider).to receive(:class).and_return(provider_class('VagrantPlugins::DockerProvider::Provider'))
      allow(provider).to receive(:host_vm).and_return(host_vm)
    end

    it 'adds an ssh ProxyCommand through the host VM when force_host_vm is set' do
      allow(provider_config).to receive(:force_host_vm).and_return(true)

      provisioner.provision

      proxy = Specinfra.configuration.ssh_options[:proxy]
      expect(proxy).to be_a(Net::SSH::Proxy::Command)
      expect(proxy.command_line_template).to include('-i /tmp/host_vm_key -p 22 docker@10.0.0.5 nc %h %p')
    end

    it 'does not use a proxy when force_host_vm is false' do
      provisioner.provision
      expect(Specinfra.configuration.ssh_options).not_to have_key(:proxy)
    end
  end

  describe 'winrm backend' do
    let(:vm_config) { double('vm_config', communicator: :winrm) }
    let(:winrm_config) { double('winrm', username: 'vagrant', password: 'vagrant', timeout: 1800) }
    let(:machine_config) { double('machine_config', vm: vm_config, winrm: winrm_config) }

    before do
      allow(provider).to receive(:class).and_return(provider_class('VagrantPlugins::HyperV::Provider'))
      allow(VagrantPlugins::CommunicatorWinRM::Helper).to receive(:winrm_info)
        .with(machine).and_return(host: '192.0.2.20', port: 5985)
    end

    after do
      # Leave a clean ssh backend for the other examples.
      set :backend, :ssh
      Specinfra.configuration.winrm = nil
    end

    it 'configures a WinRM connection for specinfra' do
      provisioner.provision

      expect(Specinfra.configuration.backend).to eq(:winrm)
      expect(Specinfra.configuration.os).to include(family: 'windows')

      conn = Specinfra.configuration.winrm
      expect(conn).to be_a(WinRM::Connection)
      opts = conn.instance_variable_get(:@connection_opts)
      expect(opts[:endpoint]).to eq('http://192.0.2.20:5985/wsman')
      expect(opts[:user]).to eq('vagrant')
      expect(opts[:password]).to eq('vagrant')
      expect(opts[:operation_timeout]).to eq(1800)
    end
  end
end
