# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = "bento/ubuntu-18.04"
  config.vm.network "private_network", ip: "192.168.33.10"

  config.vm.synced_folder "./", "/app"

  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    # 仮想マシンの名前
    vb.name = 'n_uw_f'
  end

    config.vm.provision "shell", inline: <<-SHELL
    sudo chmod 777 /vagrant/setup.sh
    /vagrant/setup.sh
  SHELL
end
