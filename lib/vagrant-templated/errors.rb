module Vagrant
  module Errors
    class VagrantfileTemplatedExistsError < VagrantError
      error_key(:vagrantfile_templated_exists)
    end

    class BerksfileTemplatedExistsError < VagrantError
      error_key(:berksfile_templated_exists)
    end

    class VagrantTemplatedOptionNotFound < VagrantError
      error_key(:vagrant_templated_option_not_found)
    end
  end
end
