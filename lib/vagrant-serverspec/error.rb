module Vagrant
  module Errors
    class ServerSpecFailed < VagrantError
      error_key(:serverspec_failed)
    end
    class ServerSpecFailedHtml < VagrantError
      error_key(:serverspec_failed_html)
    end
    class ServerSpecFilesNotFound < VagrantError
      error_key(:serverspec_filesnotfound)
    end
  end
end
