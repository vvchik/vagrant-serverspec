require 'vagrant'
require 'vagrant-serverspec'
# Vagrant loads these lazily from the plugin's config/provisioner blocks.
require 'vagrant-serverspec/config'
require 'vagrant-serverspec/provisioner'

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.order = :random
  Kernel.srand config.seed
end

# Vagrant's communicators are only loaded when a machine is created;
# the provisioner's winrm code path needs the real helper.
require Vagrant.source_root.join('plugins/communicators/winrm/helper').to_s
