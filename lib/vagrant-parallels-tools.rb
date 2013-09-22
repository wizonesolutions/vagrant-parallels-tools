begin
  require "vagrant"
rescue LoadError
  raise "The Vagrant Parallels Tools plugin must be run within Vagrant."
end

# Add our custom translations to the load path
I18n.load_path << File.expand_path("../../locales/en.yml", __FILE__)

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

require 'vagrant-parallels-tools/middleware'

module VagrantParallelsTools

  class Plugin < Vagrant.plugin("2")

    name "prltools management"
    description <<-DESC
    Provides automatic and/or manual management of the
    Parallels Tools inside the Vagrant environment.
    DESC

    config('prltools') do
      require File.expand_path("../vagrant-parallels-tools/config", __FILE__)
      Config
    end

    command('prltools') do
      Command
    end

    # hook after anything that boots:
    # that's all middlewares which will run the buildin "VM::Boot" action
    action_hook(self::ALL_ACTIONS) do |hook|
      hook.after(VagrantPlugins::Parallels::Action::Boot, VagrantParallelsTools::Middleware)
    end
  end
end
