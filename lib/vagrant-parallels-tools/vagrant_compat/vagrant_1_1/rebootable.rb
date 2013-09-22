require 'vagrant-parallels-tools/rebootable'

module VagrantParallelsTools
  module Helpers

    module Rebootable
      def reboot(vm, options)
        if reboot? vm, options
          simle_reboot = Vagrant::Action::Builder.new.tap do |b|
            b.use Vagrant::Action::Builtin::Call, Vagrant::Action::Builtin::GracefulHalt, :poweroff, :running do |env2, b2|
              if !env2[:result]
                b2.use VagrantPlugins::Parallels::Action::ForcedHalt
              end
            end
            b.use VagrantPlugins::Parallels::Action::Boot
          end
          @env[:action_runner].run(simle_reboot, @env)
        end
      end

      # executes the whole reboot process
      def reboot!(vm, options)
        if reboot? vm, options
          vm.action(:reload, options)
        end
      end
    end

  end
end
