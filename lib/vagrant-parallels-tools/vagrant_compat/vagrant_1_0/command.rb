require 'vagrant-parallels-tools/command'
require 'vagrant/command/start_mixins'

module VagrantParallelsTools

  class Command < Vagrant::Command::Base
    include CommandCommons
    include Vagrant::Command::StartMixins

    def check_runable_on(vm)
      raise Vagrant::Errors::VMNotCreatedError if !vm.created?
      raise Vagrant::Errors::VMInaccessible if !vm.state == :inaccessible
      raise Vagrant::Errors::VMNotRunningError if vm.state != :running
    end
  end

end
