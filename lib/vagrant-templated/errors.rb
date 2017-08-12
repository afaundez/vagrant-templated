module Vagrant
  module Templated
    module Errors
      class VagrantfileExistsError < Vagrant::Errors::VagrantError
        error_key(:vagrant_templated_vagrantfile_exists)
      end

      class BerksfileExistsError < Vagrant::Errors::VagrantError
        error_key(:vagrant_templated_berksfile_exists)
      end

      class TemplateNotFound < Vagrant::Errors::VagrantError
        error_key(:vagrant_templated_template_not_found)
      end

      class VersionNotFound < Vagrant::Errors::VagrantError
        error_key(:vagrant_templated_version_not_found)
      end

      class BerksfileWriteError < Vagrant::Errors::VagrantError
        error_key(:vagrant_templated_berksfile_write_error)
      end

      class VagrantfileWriteError < Vagrant::Errors::VagrantError
        error_key(:vagrant_templated_vagrantfile_write_error)
      end
    end
  end
end
