require 'spec_helper'
require 'tmpdir'

describe VagrantPlugins::ServerSpec::Config do
  subject(:config) { described_class.new }

  let(:machine) { double('machine') }

  around do |example|
    Dir.mktmpdir('vagrant-serverspec') do |dir|
      Dir.chdir(dir) do
        FileUtils.mkdir_p('spec')
        File.write('spec/a_spec.rb', '')
        File.write('spec/b_spec.rb', '')
        File.write('spec/skip_me_spec.rb', '')
        example.run
      end
    end
  end

  describe 'defaults' do
    before { config.finalize! }

    it 'has no spec files' do
      expect(config.spec_files).to eq([])
    end

    it 'enables error_no_spec_files' do
      expect(config.error_no_spec_files_found).to be(true)
    end

    it 'disables html and junit output' do
      expect(config.html_output_format).to be(false)
      expect(config.junit_output_format).to be(false)
      expect(config.junit_output_format_file_name).to be(false)
    end

    it 'fails validation because there are no spec files' do
      result = config.validate(machine)
      expect(result['serverspec provisioner']).to include('You must list at least one spec file')
    end
  end

  describe '#pattern=' do
    it 'globs the matching files' do
      config.pattern = 'spec/*_spec.rb'
      config.finalize!

      expect(config.spec_pattern).to eq('spec/*_spec.rb')
      expect(config.spec_files).to contain_exactly('spec/a_spec.rb', 'spec/b_spec.rb', 'spec/skip_me_spec.rb')
    end

    it 'passes validation when files exist' do
      config.pattern = 'spec/*_spec.rb'
      config.finalize!

      expect(config.validate(machine)).to eq('serverspec provisioner' => [])
    end

    it 'reports missing files' do
      config.spec_files = ['spec/does_not_exist_spec.rb']
      config.finalize!

      errors = config.validate(machine)['serverspec provisioner']
      expect(errors.join).to include('spec/does_not_exist_spec.rb')
    end
  end

  describe '#exclude_pattern=' do
    it 'removes excluded files from the list' do
      config.pattern = 'spec/*_spec.rb'
      config.exclude_pattern = 'spec/skip_*_spec.rb'
      config.finalize!

      expect(config.spec_excluded_files).to eq(['spec/skip_me_spec.rb'])
      expect(config.spec_files).to contain_exactly('spec/a_spec.rb', 'spec/b_spec.rb')
    end
  end

  describe '#error_no_spec_files=' do
    it 'accepts booleans only' do
      config.error_no_spec_files = false
      config.error_no_spec_files = 'yes'
      config.finalize!
      expect(config.error_no_spec_files_found).to be(false)
    end

    it 'returns nil from validate when disabled' do
      config.error_no_spec_files = false
      config.finalize!
      expect(config.validate(machine)).to be_nil
    end
  end

  describe 'output formats' do
    it 'accepts html_output and junit_output flags' do
      config.html_output = true
      config.junit_output = true
      config.finalize!
      expect(config.html_output_format).to be(true)
      expect(config.junit_output_format).to be(true)
    end

    it 'ignores non-boolean values' do
      config.html_output = 'true'
      config.junit_output = 1
      config.finalize!
      expect(config.html_output_format).to be(false)
      expect(config.junit_output_format).to be(false)
    end

    it 'accepts only .xml junit file names' do
      config.junit_output_file = 'report.txt'
      config.finalize!
      expect(config.junit_output_format_file_name).to be(false)

      config.junit_output_file = 'report.xml'
      expect(config.junit_output_format_file_name).to eq('report.xml')
    end
  end
end
