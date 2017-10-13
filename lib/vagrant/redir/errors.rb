module Vagrant
  module Redir
    module Errors

      class RedirError < Vagrant::Errors::VagrantError
        error_namespace("vagrant_redir.errors")
      end

      class NotRunning < RedirError
        error_key(:not_running)
      end

      class Unknown < RedirError
        error_key(:unknown)
      end

    end
  end
end

