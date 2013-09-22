# This file is automatically loaded by Vagrant < 1.1
# to load any plugins. This file kicks off this plugin.
begin
  require "vagrant"
rescue LoadError
  raise "The vagrant-parallels-tools plugin must be run within Vagrant."
end

require 'vagrant-parallels-tools/core_ext/string/interpolate'

require "vagrant-parallels-tools/errors"
require 'vagrant-parallels-tools/vagrant_compat'

require 'vagrant-parallels-tools/machine'

require 'vagrant-parallels-tools/hosts/base'
require 'vagrant-parallels-tools/hosts/parallels'

require 'vagrant-parallels-tools/installer'
require 'vagrant-parallels-tools/installers/base'
require 'vagrant-parallels-tools/installers/linux'
require 'vagrant-parallels-tools/installers/debian'
require 'vagrant-parallels-tools/installers/ubuntu'
require 'vagrant-parallels-tools/installers/redhat'

require 'vagrant-parallels-tools/config'
require 'vagrant-parallels-tools/command'
require 'vagrant-parallels-tools/middleware'

Vagrant.config_keys.register(:prltools) { VagrantParallelsTools::Config }

Vagrant.commands.register(:prltools) { VagrantParallelsTools::Command }

Vagrant.actions[:start].use VagrantParallelsTools::Middleware

# Add our custom translations to the load path
I18n.load_path << File.expand_path("../../locales/en.yml", __FILE__)

