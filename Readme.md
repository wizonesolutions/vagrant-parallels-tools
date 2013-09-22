# This plugin isn't ready yet!

Currently, I'm just finding and replacing everything called vagrant-vbguest and then converting the logic to use the Parallels Tools. It's conceptually very similar to VirtualBox, and the user has the files on their machine, so it's just a matter of transferring them and running the script.

This plugin will be simpler than *vagrant-vbguest* because we only have to care about Mac OS X.

I'm developing against Parallels Desktop 8, but we'll probably need help testing Parallels Desktop 9.

# vagrant-parallels-tools

*vagrant-parallels-tools* is a [Vagrant](http://vagrantup.com) plugin which automatically installs the host's Parallels Tools on the guest system.

Based on the excellent https://github.com/dotless-de/vagrant-vbguest. If you use VirtualBox for any machines, and you aren't using that plugin, you are missing out.

## Installation

Requires vagrant 0.9.4 or later (including 1.x)

### Vagrant ≥ 1.1

```bash
$ vagrant plugin install vagrant-parallels-tools
```

## Configuration / Usage

If you're lucky, *vagrant-parallels-tools* does not require any configurations. 
However, here is an example for your `Vagrantfile`:

```ruby
Vagrant::Config.run do |config|
  # we will try to autodetect this path. 
  # However, if we cannot or you have a special one you may pass it like:
  # config.prltools.iso_path = "#{ENV['HOME']}/Downloads/VBoxGuestAdditions.iso"
  # or
  # config.prltools.iso_path = "http://company.server/VirtualBox/%{version}/VBoxGuestAdditions.iso"
  
  # set auto_update to false, if do NOT want to check the correct additions 
  # version when booting this machine
  config.prltools.auto_update = false
  
  # do NOT download the iso file from a webserver
  config.prltools.no_remote = true
end
```

### Config options

* `iso_path` : The full path or URL to the VBoxGuestAdditions.iso file. <br/>
The `iso_path` may contain the optional placeholder `%{version}` for the detected version (e.g. `4.1.8`).
The URI for the actual iso download reads: `http://download.virtualbox.org/virtualbox/%{version}/VBoxGuestAdditions_%{version}.iso`<br/>
vagrant-parallels-tools will try to autodetect the best option for your system. WTF? see below.
* `auto_update` (Boolean, default: `true`) : Whether to check the correct additions version on each start (where start is _not_ resuming a box).
* `auto_reboot` (Boolean, default: `true` when running as a middleware, `false` when running as a command) : Whether to reboot the box after GuestAdditions has been installed, but not loaded.
* `no_install` (Boolean, default: `false`) : Whether to check the correct additions version only. This will warn you about version mis-matches, but will not try to install anything.
* `no_remote` (Boolean, default: `false`) : Whether to _not_ download the iso file from a remote location. This includes any `http` location!
* `installer` (`VagrantParallelsTools::Installers::Base`, optional) : Reference to a (custom) installer class

#### Global Configuration

Using [Vagrantfile Load Order](http://vagrantup.com/v1/docs/vagrantfile.html#vagrantfile_load_order) you may change default configuration values.
Edit (create, if missing) your `~/.vagrant.d/Vagrantfile` like this:

```ruby
# vagrant's autoloading may not have kicked in
require 'vagrant-parallels-tools' unless defined? VagrantParallelsTools::Config
VagrantParallelsTools::Config.auto_update = false
```

Settings in a project's `Vagrantfile` will overwrite those setting. When executed as a command, command line arguments will overwrite all of the above.


### Running as a middleware

Running as a middleware will is the default way using *vagrant-parallels-tools*. 
It will run automatically right after the box started. This is each time the box boots, i.e. `vagrant up` or `vagrant reload`. 
It won't run on `vagrant resume` (or `vagrant up` a suspended box) to save you some time resuming a box.

You may switch off the middleware by setting the vm's config `prltools.auto_update` to `false`.
This is a per box settings. On multi vm environments you need to set that for each vm.

When *vagrant-parallels-tools* is running it will provide you some logs:

    [...]
    [default] Booting VM...
    [default] Booting VM...
    [default] Waiting for VM to boot. This can take a few minutes.
    [default] VM booted and ready for use!
    [default] GuestAdditions versions on your host (4.2.6) and guest (4.1.0) do not match.
    stdin: is not a tty
    Reading package lists...
    Building dependency tree...
    Reading state information...
    The following extra packages will be installed:
      fakeroot linux-headers-2.6.32-33 patch

    [...]

    [default] Copy iso file /Applications/VirtualBox.app/Contents/MacOS/VBoxGuestAdditions.iso into the box /tmp/VBoxGuestAdditions.iso
    stdin: is not a tty
    [default] Installing Virtualbox Guest Additions 4.2.6 - guest version is 4.1.0
    stdin: is not a tty
    Verifying archive integrity... All good.
    Uncompressing VirtualBox 4.2.6 Guest Additions for Linux...........
    VirtualBox Guest Additions installer
    Removing installed version 4.1.0 of VirtualBox Guest Additions...
    tar: Record size = 8 blocks
    Removing existing VirtualBox DKMS kernel modules ...done.
    Removing existing VirtualBox non-DKMS kernel modules ...done.
    Building the VirtualBox Guest Additions kernel modules ...done.
    Doing non-kernel setup of the Guest Additions ...done.
    You should restart your guest to make sure the new modules are actually used

    Installing the Window System drivers ...fail!
    (Could not find the X.Org or XFree86 Window System.)
    stdin: is not a tty
    [default] Restarting VM to apply changes...
    [default] Attempting graceful shutdown of VM...
    [default] Booting VM...
    [default] Waiting for VM to boot. This can take a few minutes.
    [default] VM booted and ready for use!
    [default] Configuring and enabling network interfaces...
    [default] Setting host name...
    [default] Mounting shared folders...
    [default] -- v-root: /vagrant
    [default] -- v-csc-1: /tmp/vagrant-chef-1/chef-solo-1/cookbooks
    [default] Running provisioner: Vagrant::Provisioners::ChefSolo...
    [default] Generating chef JSON and uploading...
    [default] Running chef-solo...
    [...]


The plugin's part starts at `[default] Installing Virtualbox Guest Additions 4.1.14 - guest's version is 4.1.1`, telling you that:

* the guest addition of the box *default* are outdated (or mismatch) 
* which guest additions iso file will be used 
* which installer script will be used
* all the VirtualBox Guest Additions installer output.

No worries on the `Installing the Window System drivers ...fail!`. Most dev boxes you are using won't run a Window Server, thus it's absolutely save to ignore that error.

When everything is fine, and no update is needed, you see log like:

    ...
    [default] Booting VM...
    [default] Waiting for VM to boot. This can take a few minutes.
    [default] VM booted and ready for use!
    [default] GuestAdditions 4.2.6 running --- OK.
    ...


### Running as a Command

When you switched off the middleware auto update, or you have a box up and running you may also run the installer manually.

```bash
$ vagrant prltools [vm-name] [--do start|rebuild|install] [--status] [-f|--force] [-b|--auto-reboot] [-R|--no-remote] [--iso VBoxGuestAdditions.iso]
```

For example, when you just updated Virtual Box on your host system, you should update the gust additions right away. However, you may need to reload the box to get the guest additions working.

If you want to check the guest additions versions, without installing them, you may run:

```bash
$ vagrant prltools --status
```

Telling you either about a version mismatch:

    [default] GuestAdditions versions on your host (4.2.6) and guest (4.1.0) do not match.

or a match:

    [default] GuestAdditions 4.2.6 running --- OK.


The `auto-reboot` is tured off by default, when running as a command. vagrant-parallels-tools will suggest you to reboot the box when needed. To turn it on simply pass the `--auto-reboot` parameter:

```bash
$ vagrant prltools --auto-reboot
```

You can also pass vagrant's `reload` options like:

```bash
$ vagrant prltools --auto-reboot --no-provision
```



### ISO autodetection

*vagrant-parallels-tools* will try to autodetect a VirtualBox GuestAdditions iso file on your system, which usually matches your installed version of VirtualBox. If it cannot find one, it downloads one from the web (virtualbox.org).   
Those places will be checked in order:

1. Checks your VirualBox "Virtual Media Maganger" for a DVD called "VBoxGuestAdditions.iso"
2. Guess by your host operating system:
  * for linux : `/usr/share/virtualbox/VBoxGuestAdditions.iso`
  * for Mac : `/Applications/VirtualBox.app/Contents/MacOS/VBoxGuestAdditions.iso`
  * for Windows : `%PROGRAMFILES%/Oracle/VirtualBox/VBoxGuestAdditions.iso`


### Automatic reboot

The VirtualBox GuestAdditions Installer will try to load the newly build kernel module. However the installer my fail to do, just as it is happening when updating GuestAdditions from version 4.1 to 4.2.

Hency, vagrant-parallels-tools will check for a loaded kernel module after the installation has finished and reboots the box, if it could not find one.


## Advanced Usage

vagrant-parallels-tools provides installers for generic linux and debian/ubuntu.  
Installers take care of the whole installation process, that includes where to save the iso file inside the guest and where to mount it.

```ruby
class MyInstaller < VagrantParallelsTools::Installers::Linux

  # use /temp instead of /tmp
  def tmp_path
    '/temp/VBoxGuestAdditions.iso'
  end

  # use /media instead of /mnt
  def mount_point
    '/media'
  end

  def install(opts=nil, &block)
    communicate.sudo('my_distos_way_of_preparing_guestadditions_installation', opts, &block)
    # calling `super` will run the installation
    # also it takes care of uploading the right iso file into the box
    # and cleaning up afterward
    super
  end
end

Vagrant::Config.run do |config|
  config.prltools.installer = MyInstaller
end
```


## Known Issues

* The installer script, which mounts and runs the Parallels Tools Installer Binary, works on linux only. Most likely it will run on most unix-like plattform.
* The installer script requires a directory `/mnt` on the guest system
* On multi vm boxes, the iso file will be downloaded for each vm
