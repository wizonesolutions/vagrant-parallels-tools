module VagrantParallelsTools
  module Hosts
    class ParallelsTools < Base

      protected

        # Finds Parallels Tools iso file on the host system.
        # Returns +nil+ if none found.
        #
        # @return [String] Absolute path to the local Parallels Tools iso file, or +nil+ if not found.
        def local_path
          media_manager_iso || guess_local_iso
        end

        # Kicks off +VagrantParallelsTools::Download+ to download the additions file
        # into a temp file.
        #
        # To remove the created tempfile call +cleanup+
        #
        # @param [String] The path or URI to download
        #
        # @return [String] The path to the downloaded file
        def download(path)
          temp_path = File.join(@env.tmp_path, "VBoxGuestAdditions_#{version}.iso")
          @download = VagrantParallelsTools::Download.new(path, temp_path, :ui => @env.ui)
          @download.download!
          @download.destination
        end

      private

        # Helper method which queries optical drives via prlctl
        # for the first existing path that looks like a
        # +VBoxGuestAdditions.iso+ file.
        #
        # @return [String] Absolute path to the local Parallels Tools iso file, or +nil+ if not found.
        def media_manager_iso
          driver.execute('list', 'dvds').scan(/^.+:\s+(.*VBoxGuestAdditions(?:_#{version})?\.iso)$/i).map { |path, _|
            path if File.exist?(path)
          }.compact.first
        end

        # Find the first Parallels Tools iso file which exists on the host system
        #
        # @return [String] Absolute path to the local Parallels Tools iso file, or +nil+ if not found.
        def guess_local_iso
          Array(platform_path).find do |path|
            path && File.exists?(path)
          end
        end

        # Makes an educated guess where the Parallels Tools iso file
        # could be found on the host system depending on the OS.
        # Returns +nil+ if no the file is not in it's place.
        def platform_path
          [:darwin].each do |sys|
            return self.send("#{sys}_path") if Vagrant::Util::Platform.respond_to?("#{sys}?") && Vagrant::Util::Platform.send("#{sys}?")
          end
          nil
        end

        # Makes an educated guess where the Parallels Tools iso file
        # on Macs
        def darwin_path
          # TODO: Does this work with Parallels Desktop 9?
          parallels_base_path = "/Applications/Parallels Desktop.app/Contents/Resources/Tools"

          #
        end

        # overwrite the default version string to allow lagacy
        # '$VBOX_VERSION' as a placerholder
        def versionize(path)
          super(path.gsub('$VBOX_VERSION', version))
        end

    end
  end
end
