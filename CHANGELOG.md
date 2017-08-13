# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.2.0] - 2017-08-12
### Added
- Node.js 6 template
- Cat option
### Changed
- Refactor config directories
- Lock chef version for all templates
- Move version from template name to a new option. If version not provided, using largest version
- Refactor loading and accessing template attributes
- Creating all error in vagrant templated module
- Update vagrantfile and berksfile
- Replace suffix with output option
- Update readme
## Removed
- Vagrantfile's magic comments
- Extra empty lines in templates


## [0.1.5] - 2017-08-07
### Added
- Update Vagrantfile from vagrant-templated
- Moving from timezone-ii to timezone_iii recipe
- Add badges at readme
- Add contributing guide

## [0.1.4] - 2017-08-05
### Added
- Test all templates
- Add comment attribute to private network
- Add django1.11 template, with pyenv, including python 2 and 3
- Add basic template, only apt and tz update
- Add private network configuration and use it at rails5 template

## [0.1.3] - 2017-08-05
### Added
- Refactor defaults to attributes, it's more self documented now
- Move chef version to configuration files, fixing rails5 chef problem
- Templates displayed at help generated with yml information
- Refactor templates file structure: one yml per template

## [0.1.2] - 2017-08-04
### Added
- Fix locale load

## [0.1.0] - 2017-08-04
### Added
- Fix gesmpec dependencies

## [0.1.0] - 2017-08-04
### Added
- Add init command with two templates: rails5 and vagrant-plugin
