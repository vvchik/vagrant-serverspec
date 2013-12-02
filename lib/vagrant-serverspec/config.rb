module VagrantPlugins
  module ServerSpec
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :spec_files

      def initialize
        super
        @spec_files = UNSET_VALUE
      end

      def pattern=(pat)
        @spec_files = Dir.glob(pat)
      end

      def finalize!
        @spec_files = [] if @spec_files == UNSET_VALUE
      end

      def validate(machine)
        errors = _detected_errors

        if @spec_files.nil? || @spec_files.empty?
          errors << I18n.t('vagrant.config.serverspec.no_spec_files')
        end

        missing_files = @spec_files.select { |path| !File.file?(path) }
        unless missing_files.empty?
          errors << I18n.t('vagrant.config.serverspec.missing_spec_files', files: missing_files.join(', '))
        end

        { 'serverspec provisioner' => errors }
      end
    end
  end
end
