# -*- encoding: utf-8 -*-
require File.expand_path('../lib/vagrant-parallels-tools/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = "vagrant-parallels-tools"
  s.version     = VagrantParallelsTools::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Robert Schulze"]
  s.email       = ["robert@dotless.de"]
  s.license     = 'MIT'
  s.homepage    = "https://github.com/wizonesolutions/vagrant-parallels-tools"
  s.summary     = %q{A Vagrant plugin to install the Parallels Tools into the guest VM}
  s.description = %q{A Vagrant plugin which automatically installs the host's Parallels Tools on the guest system.}

  s.required_rubygems_version = ">= 1.3.6"

  s.add_dependency "micromachine", "~> 1.1.0"
  s.add_dependency "i18n", "~> 0.6.0"
  s.add_dependency "log4r", "~> 1.1.9"

  s.add_development_dependency "bundler", ">= 1.2.0"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

end
