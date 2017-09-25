module VagrantPlugins
  module ServerSpec
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :spec_files
      attr_accessor :spec_pattern
      attr_accessor :error_no_spec_files_found
      attr_accessor :html_output_format

      def initialize
        super
        @spec_files = UNSET_VALUE
        @html_output_format = UNSET_VALUE
        @error_no_spec_files_found = UNSET_VALUE
      end

      def pattern=(pat)
        @spec_files = Dir.glob(pat)
        @spec_pattern = pat
      end

      def error_no_spec_files=(warn_spec)
        if [true, false].include? warn_spec
          @error_no_spec_files_found = warn_spec
        end
      end

      def html_output=(html_out)
        if [true, false].include? html_out
          @html_output_format = html_out
        end
      end

      def finalize!
        @spec_files = [] if @spec_files == UNSET_VALUE
        @html_output_format = false if @html_output_format == UNSET_VALUE
        @error_no_spec_files_found = true if @error_no_spec_files_found == UNSET_VALUE
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

        if @error_no_spec_files_found
          { 'serverspec provisioner' => errors }
        end
      end
    end
  end
end
