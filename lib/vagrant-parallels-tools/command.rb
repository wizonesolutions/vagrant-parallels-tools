require 'optparse'

module VagrantParallelsTools

  module CommandCommons
    include VagrantParallelsTools::Helpers::Rebootable
    def self.included(base)
      base.extend(ClassMethods)
    end

    # Runs the prltools installer on the VMs that are represented
    # by this environment.
    def execute
      options = {
        :_method => :run,
        :_rebootable => true,
        :auto_reboot => false
      }
      opts = OptionParser.new do |opts|
        opts.banner = "Usage: vagrant prltools [vm-name] [--do start|rebuild|install] [--status] [-f|--force] [-b|--auto-reboot] [-R|--no-remote] [--iso prl-tools-{lin,mac,win,other}.iso]"
        opts.separator ""

        opts.on("--do COMMAND", [:start, :rebuild, :install], "Manually `start`, `rebuild` or `install` GueastAdditions.") do |command|
          options[:_method] = command
          options[:force] = true
        end

        opts.on("--status", "Print current Parallels Tools status and exit.") do
          options[:_method] = :status
          options[:_rebootable] = false
        end

        opts.on("-f", "--force", "Whether to force the installation. (Implied by --do start|rebuild|install)") do
          options[:force] = true
        end

        opts.on("--auto-reboot", "-b", "Allow rebooting the VM after installation. (when Parallels Tools won't start)") do
          options[:auto_reboot] = true
        end

        opts.on("--no-remote", "-R", "Do not attempt do download the iso file from a webserver") do
          options[:no_remote] = true
        end

        opts.on("--iso file_or_uri", "Full path or URI to the Parallels Tools ISO file") do |file_or_uri|
          options[:iso_path] = file_or_uri
        end

        build_start_options(opts, options)
      end


      argv = parse_options(opts)
      return if !argv

      if argv.empty?
        with_target_vms(nil) { |vm| execute_on_vm(vm, options) }
      else
        argv.each do |vm_name|
          with_target_vms(vm_name) { |vm| execute_on_vm(vm, options) }
        end
      end

    end

    protected

    # Executes a command on a specific VM.
    def execute_on_vm(vm, options)
      check_runable_on(vm)

      options     = options.clone
      _method     = options.delete(:_method)
      _rebootable = options.delete(:_rebootable)

      options = vm.config.prltools.to_hash.merge(options)
      machine = VagrantParallelsTools::Machine.new(vm, options)
      status  = machine.state
      vm.env.ui.send((:ok == status ? :success : :warn), I18n.t("vagrant_parallels_tools.status.#{status}", machine.info))

      if _method != :status
        machine.send(_method)
      end

      reboot!(vm, options) if _rebootable && machine.reboot?
    rescue VagrantParallelsTools::Installer::NoInstallerFoundError => e
      vm.env.ui.error e.message
    end

    def check_runable_on(vm)
      raise NotImplementedError
    end
  end

end
