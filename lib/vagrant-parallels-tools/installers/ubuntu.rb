module VagrantParallelsTools
  module Installers
    class Ubuntu < Debian

      def self.match?(vm)
        :ubuntu == self.distro(vm)
      end

    end
  end
end
VagrantParallelsTools::Installer.register(VagrantParallelsTools::Installers::Ubuntu, 5)