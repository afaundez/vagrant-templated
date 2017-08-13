begin
  require 'vagrant'
rescue LoadError
  Bundler.require(:default, :development)
end

require 'vagrant-templated/version'
require 'vagrant-templated/plugin'
require 'vagrant-templated/errors'
require 'vagrant-templated/catalog'
require 'vagrant-templated/command/root'
require 'vagrant-templated/command/init'

require 'i18n'
I18n.load_path << Dir.glob(File.join(File.dirname(File.expand_path(__FILE__)), "../config/locales/*.{rb,yml}"))
