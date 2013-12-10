module VagrantPlugins
  module ServerSpec
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :spec_files, :exclusion_filter

      def initialize
        super
        @spec_files        = UNSET_VALUE
        @exclusioin_filter = UNSET_VALUE
      end

      def pattern=(pattern)
        @spec_files = Dir.glob(pattern)
      end

      def excludes=(excludes)
        @exclusion_filter = excludes.reduce({}) {|mem, ex| mem[ex.to_sym] = true; mem }
      end

      def finalize!
        @spec_files       = []  if @spec_files       == UNSET_VALUE
        @exclusion_filter = nil if @exclusion_filter == UNSET_VALUE
      end

      def validate(machine)
        errors = _detected_errors

        unless (@spec_files.nil? || @spec_files.empty?)
          missing_files = @spec_files.select { |path| !File.file?(path) }
          unless missing_files.empty?
            errors << I18n.t('vagrant.config.serverspec.missing_spec_files', files: missing_files.join(', '))
          end
        end

        { 'serverspec command' => errors }
      end

    end

  end
end
