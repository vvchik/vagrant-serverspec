module Vagrant
  module Errors
    class ServerSpecFailed < VagrantError
      error_key(:serverspec_failed)
    end
  end
end
