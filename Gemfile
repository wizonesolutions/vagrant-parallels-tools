source 'https://rubygems.org'

# Specify your gem's dependencies in vagrant-parallels-tools.gemspec
gemspec

group :development do
  # We depend on Vagrant for development, but we don't add it as a
  # gem dependency because we expect to be installed within the
  # Vagrant environment itself using `vagrant plugin`.
  gem "vagrant", :git => "git://github.com/mitchellh/vagrant.git"

  # Same deal for vagrant-parallels; they need to install it separately.

  # REMOVE # WHEN DEVELOPING AND FIX PATH TO vagrant-parallels IF NECESSARY
  gem "vagrant-parallels", :path => "~/.vagrant.d/gems/gems/vagrant-parallels-0.0.1"
end
