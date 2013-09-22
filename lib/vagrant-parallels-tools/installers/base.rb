module VagrantParallelsTools
  module Installers
    class Error < Vagrant::Errors::VagrantError
      error_namespace "vagrant_parallels_tools.errors.installer"
    end

    # This is the base class all installers must inherit from
    # It defines the basic structure of an Installer and should
    # never be used directly
    class Base
      include VagrantParallelsTools::Helpers::VmCompatible

      # Tests whether this installer class is applicable to the
      # current environment. Usually, testing for a specific OS.
      # Subclasses must override this method and return `true` if
      # they wish to handle.
      #
      # This method will be called only when an Installer detection
      # is run. It is ignored, when passing an Installer class
      # directly as an config (`installer`) option.
      #
      # @param [Vagrant::VM]
      # @return [Boolean]
      def self.match?(vm)
        false
      end

      attr_reader :env, :vm, :options, :host

      def initialize(vm, options=nil)
        @vm = vm
        @env = vm.env
        @options = options

        @host = VagrantParallelsTools::Hosts::ParallelsTools.new(vm, options)
      end

      # The absolute file path of the Parallels Tools iso file should
      # be uploaded into the guest.
      # Subclasses must override this method!
      #
      # @return [String]
      def tmp_path
      end

      # The mountpoint path
      # Subclasses shall override this method, if they need to mount the uploaded file!
      #
      # @return [String]
      def mount_point
      end

      # Handles the installation process.
      # All necessary steps for an installation must be defined here.
      # This includes uploading the iso into the box, mounting,
      # installing and cleaning up.
      # The path to the local iso file should be obtained by calling +iso_file+
      # Subclasses must override this method!
      #
      # @param [Hash] opts Optional options Hash wich meight get passed to {Vagrant::Communication::SSH#execute} and firends
      # @yield [type, data] Takes a Block like {Vagrant::Communication::Base#execute} for realtime output of the command being executed
      # @yieldparam [String] type Type of the output, `:stdout`, `:stderr`, etc.
      # @yieldparam [String] data Data for the given output.
      def install(opts=nil, &block)
      end

      # Handels the rebuild of allready running Parallels Tools
      # It may happen, that the guest has the correct Parallels Tools
      # version running, but not the kernel module is not running.
      # This method should perform a rebuild or try to reload the
      # kernel module _without_ the Parallels Tools iso file.
      # If there is no way of rebuidling or reloading the
      # Parallels Tools on a specific system, this method should left
      # empty.
      # Subclasses should override this method.
      #
      # @param [Hash] opts Optional options Hash wich meight get passed to {Vagrant::Communication::SSH#execute} and firends
      # @yield [type, data] Takes a Block like {Vagrant::Communication::Base#execute} for realtime output of the command being executed
      # @yieldparam [String] type Type of the output, `:stdout`, `:stderr`, etc.
      # @yieldparam [String] data Data for the given output.
      def rebuild(opts=nil, &block)
      end

      # Restarts the allready installed Parallels Tools
      # It may happen, that the guest has the correct Parallels Tools
      # version installed, but for some reason are not (yet) runnig.
      # This method should execute the Parallels Tools system specific
      # init script in order to start it manually.
      # If there is no way of doing this on a specific system,
      # this method should left empty.
      # Subclasses should override this method.
      #
      # @param [Hash] opts Optional options Hash wich meight get passed to {Vagrant::Communication::SSH#execute} and firends
      # @yield [type, data] Takes a Block like {Vagrant::Communication::Base#execute} for realtime output of the command being executed
      # @yieldparam [String] type Type of the output, `:stdout`, `:stderr`, etc.
      # @yieldparam [String] data Data for the given output.
      def start(opts=nil, &block)
      end

      # Determinates if the Parallels Tools kernel module is loaded.
      # This method tests if there is a working Parallels Tools
      # kernel module. If there is none, {#rebuild} is beeing called.
      # If there is no way of telling if there is a working
      # GuestAddition for a specific system, this method should
      # return `true`.
      # Subclasses should override this method.
      #
      # @return [Boolean] `true` if the kernel module is loaded (and thus seems to work), `false` otherwise.
      def running?(opts=nil, &block)
        true
      end

      # Determinates the Parallels Tools version installed on the
      # guest system.
      #
      # @param [Boolean] reload Whether to read the value again or use
      #                  the cached value form an erlier call.
      # @return [String] The version code of the Parallels Tools
      #                  available on the guest, or `nil` if none installed.
      def guest_version(reload=false)
        return @guest_version if @guest_version && !reload

        guest_version = driver.read_guest_tools_version
        guest_version = !guest_version ? nil : guest_version.gsub(/[-_]ose/i, '')

        @guest_version = guest_version
      end


      # Determinates the version of the Parallels Tools installer in use
      #
      # @return [String] The version code of the Parallels Tools installer
      def installer_version(path_to_installer)
        version = nil
        communicate.sudo("#{path_to_installer} --info", :error_check => false) do |type, data|
          if (v = data.to_s.match(/\AIdentification.*\s(\d+\.\d+.\d+)/i))
            version = v[1]
          end
        end
        version
      end

      # Helper to yield a warning message to the user, that the installation
      # will start _now_.
      # The message includes the host and installer version strings.
      def yield_installation_waring(path_to_installer)
        @env.ui.warn I18n.t("vagrant_parallels_tools.installing#{@options[:force] ? '_forced' : ''}",
          :guest_version => guest_version,
          :installer_version => installer_version(path_to_installer) || I18n.t("vagrant_parallels_tools.unknown"))
      end

      # Helper to yield a warning message to the user, that the installation
      # will be rebuild using the installed Parallels Tools.
      # The message includes the host and installer version strings.
      def yield_rebuild_warning
        @env.ui.warn I18n.t("vagrant_parallels_tools.rebuild#{@options[:force] ? '_forced' : ''}",
          :guest_version => guest_version(true),
          :host_version => @host.version)
      end

      # Helper to yield a warning message to the user in the event that the
      # installer returned a non-zero exit status. We don't want to
      # kill the entire boot process, but we do want to make sure the user
      # knows there could be a problem. The message includes the installer
      # version.
      def yield_installation_error_warning(path_to_installer)
        @env.ui.warn I18n.t("vagrant_parallels_tools.install_error",
          :installer_version => installer_version(path_to_installer) || I18n.t("vagrant_parallels_tools.unknown"))
      end

      def iso_file
        @host.additions_file
      end
      alias_method :additions_file, :iso_file

      # A helper method to handle the Parallels Tools iso file upload
      # into the guest box.
      # The file will uploaded to the location given by the +temp_path+ method.
      #
      # @example Default upload
      #    upload(file)
      #
      # @param [String] Path of the file to upload to the +tmp_path*
      def upload(file)
        env.ui.info(I18n.t("vagrant_parallels_tools.start_copy_iso", :from => file, :to => tmp_path))
        communicate.upload(file, tmp_path)
      end

      # A helper method to delete the uploaded Parallels Tools iso file
      # from the guest box
      def cleanup
        @host.cleanup
        communicate.execute("test -f #{tmp_path} && rm #{tmp_path}", :error_check => false) do |type, data|
          env.ui.error(data.chomp, :prefix => false)
        end
      end

    end
  end
end
