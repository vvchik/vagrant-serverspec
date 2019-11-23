module Vagrant
  module Errors
    class ServerSpecFailed < VagrantError
      error_key(:serverspec_failed)
    end
    class ServerSpecFailedHtml < VagrantError
      error_key(:serverspec_failed_html)
    end
    class ServerSpecFailedHtmlJunit < VagrantError
      error_key(:serverspec_failed_html_junit)
    end
    class ServerSpecFailedJunit < VagrantError
      error_key(:serverspec_failed_junit)
    end
    class ServerSpecFilesNotFound < VagrantError
      error_key(:serverspec_filesnotfound)
    end
  end
end
