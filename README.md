[![GitHub version](https://badge.fury.io/gh/afaundez%2Fvagrant-templated.svg)](https://badge.fury.io/gh/afaundez%2Fvagrant-templated)
[![Gem Version](https://badge.fury.io/rb/vagrant-templated.svg)](https://badge.fury.io/rb/vagrant-templated)

# VAGRANT TEMPLATED PLUGIN

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
vagrant templated init <template> [version]
```

The templates available at this moment are:

- `base`
  - `1.0`: apt and timezone update
- `vagrant-plugin`:
  - `1.9`: base and ruby 2.3
- `django`:
  - `1.11`: base, python 2/3 (pyenv)
- `rails`:
  - `5.1`: base, ruby 2.4 (rbenv), node and postgresql.
- `nodejs`:
  - `6.11`: base, node 6.11 (nodenv)

In both cases a Vagrantfile and a Berksfile will be generated where you executing the command.

## Development

After checking out the repo, you just should `vagrant up` and enter the matrix. Everything is at `/vagrant`.

Inside the box run `bundle install` to install dependencies. Then, run `bundle exec rake spec` to run the tests. Run `bundle exec vagrant templated init -h` and help will arise.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/afaundes/vagrant-templated. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## TODO list

- Add multiple choices for some components. For example, rails5 add postgresql by default, but it could be mysql or sqlite3 (that what I have used). Maybe it would better to add everything and leave everything commented but one default.
- Display ad hoc tips when new files are created
- Add tips as a command

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Vagrant::Templated project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/afaundes/vagrant-templated/blob/master/CODE_OF_CONDUCT.md).
