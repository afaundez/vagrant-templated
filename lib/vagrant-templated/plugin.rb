module Vagrant
  module Templated
    class Plugin < Vagrant.plugin('2')
      name 'vagrant templated'
      description 'The `templated` command gives you a way to init a project with a templated Vagrantfile'

      command 'templated' do
        require_relative 'command/root'
        Command::Root
      end
    end
  end
end
