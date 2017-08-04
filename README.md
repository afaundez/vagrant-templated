# Vagrant Templated Plugin

Vagrant Templated is [Vagrant](https://www.vagrantup.com/downloads.html) plugin that add a new vagrant action to start a new Project. You will be able to choose between templates and start with a project with a Vagrantfile (and Berksfile) with cookbooks and configurations.

I started this gem because every time I start a new project, for production or just testing something, after the traditional vagrant init I had look in others projects looking for a specific configuration (for example, a Rails 5 project)

## Installation

With vagrant:

```shell
vagrant plugin install vagrant-templated
```

To use the Vagranfile and Berksfile created, you will need [chefdk](https://downloads.chef.io/chefdk), [vagrant-berkshelf](https://github.com/berkshelf/vagrant-berkshelf) and  [vagrant-omnibus](https://github.com/chef/vagrant-omnibus).


## Usage

The new init action runs like this:

```shell
vagrant templated init <template>
```

The templates available at this moment are `rails5` and `vagrant-plugin`.

In both cases a Vagrantfile and a Berksfile will be generated where you executing the command.

Then, you just should `vagrant up` and enter the matrix.

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `bundle exec rake spec` to run the tests. Run `bundle exec vagrant templated init -h` and help will arise.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/afaundes/vagrant-templated. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Vagrant::Templated project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/afaundes/vagrant-templated/blob/master/CODE_OF_CONDUCT.md).
