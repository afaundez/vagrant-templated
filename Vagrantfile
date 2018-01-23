# vagrant-templated vagrantfile for vagrant-plugin 1.9
# check https://github.com/afaundez/vagrant-templated for more options
["vagrant-omnibus", "vagrant-berkshelf"].each do |plugin_name|
  unless Vagrant.has_plugin? plugin_name
    raise "#{plugin_name} plugin is required. Please run `vagrant plugin install #{plugin_name}`"
  end
end

Vagrant.configure('2') do |config|
  config.vm.box = 'bento/ubuntu-16.04'
  config.omnibus.chef_version = '13.2.20'
  config.vm.provision :chef_solo do |chef|
    chef.add_recipe 'apt'
    chef.add_recipe 'ruby_build'
    chef.add_recipe 'ruby_rbenv::user'

    chef.json = {
      "rbenv": {
        "user_installs": [
          {
            "user": "vagrant",
            "rubies": [
              "2.2.9"
            ],
            "global": "2.2.9",
            "gems": {
              "2.2.9": [
                {
                  "name": "bundler"
                }
              ]
            }
          }
        ]
      }
    }
  end
end
