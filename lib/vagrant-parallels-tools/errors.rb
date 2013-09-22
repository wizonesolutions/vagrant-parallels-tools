module VagrantParallelsTools

  class ParallelsToolsError < Vagrant::Errors::VagrantError
    def error_namespace; "vagrant_parallels_tools.errors"; end
  end

  class IsoPathAutodetectionError < VagrantParallelsTools::ParallelsToolsError
    error_key :autodetect_iso_path
  end

  class DownloadingDisabledError < VagrantParallelsTools::ParallelsToolsError
    error_key :downloading_disabled
  end

  class NoParallelsMachineError < VagrantParallelsTools::ParallelsToolsError
    error_key :no_parallels_machine
  end
end
