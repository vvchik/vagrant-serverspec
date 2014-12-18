require 'vagrant-serverspec/plugin'
require 'vagrant-serverspec/version'
require 'vagrant-serverspec/error'

module VagrantPlugins
  module ServerSpec
    def self.source_root
      @source_root ||= Pathname.new(File.expand_path('../../', __FILE__))
    end

    I18n.load_path << File.expand_path('locales/en.yml', source_root)
    I18n.reload!
  end
end
