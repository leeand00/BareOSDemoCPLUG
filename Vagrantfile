# 0. Make sure the `vagrant-hostmanager` plugin is already installed using `vagrant plugin list` if not install it from https://github.com/devopsgroup-io/vagrant-hostmanager
# 0. Make sure that the `vagrant-vbguest` plugin is installed.
# 1. Run `vagrant up`
# 2. Run `vagrant hostmanager`

# Setup the Puppet Client (bareos)
$puppetServerScript = <<SCRIPT
sudo wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
sudo wget http://www.cmake.org/files/v3.2/cmake-3.2.3-Linux-x86_64.tar.gz
sudo dpkg -i puppetlabs-release-trusty.deb
sudo apt-get update
sudo apt-get --assume-yes install puppetmaster
sudo apt-get --assume-yes autoremove
sudo echo "Installing bareos https://forge.puppet.com/netmanagers/bareos/readme"
sudo puppet module install netmanagers-bareos --version 1.0.0 
SCRIPT


# Setup the Puppet Client (bareos dir)
$puppetClientBareOSdir = <<SCRIPT1
sudo wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
sudo dpkg -i puppetlabs-release-trusty.deb
sudo apt-get --assume-yes install puppet
SCRIPT1

# Setup the Puppet Client (web server)
$puppetClientWebserver = <<SCRIPT2
sudo wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb
sudo dpkg -i puppetlabs-release-trusty.deb
sudo apt-get --assume-yes install puppet
SCRIPT2

Vagrant.configure(2) do |config|
  
  config.vm.box = "leeand00/turnkey-lamp-14.2"

  config.vm.provider "virtualbox" do |vb|
      vb.cpus = 2
      #vb.gui = true
  end
  
  config.vm.boot_timeout = 10000
  config.vm.network "private_network", type: "dhcp"

  #config.vm.provision :hostmanager

  config.ssh.insert_key = false
  #config.ssh.private_key_path = "/mnt/vm_lab/vagrant_box_storage/.vagrant.d/insecure_private_key"
  config.ssh.forward_agent = true

  #config.ssh.username = "root"
  #config.ssh.password = "turnkeyAvB12"

  config.hostmanager.enabled = true
  config.hostmanager.manage_guest = true
  #config.hostmanager.manage_host = true

  # How you set static IPs in virtualbox: 
  # https://stackoverflow.com/questions/44556931/vagrant-hostmanager-1-8-6-error-when-updating-guest-hosts
  config.hostmanager.ip_resolver = proc do |vm, resolving_vm|
      if vm.id
         `VBoxManage guestproperty get #{vm.id} "/VirtualBox/GuestInfo/Net/2/V4/IP"`.split()[1]
      end
  end

  config.vm.define :puppet_server do |srv|
      srv.vm.hostname = "puppet-server"
      srv.vm.network :private_network, ip: '10.0.3.15'
      srv.vm.provision "shell", inline: $puppetServerScript 
      srv.vm.synced_folder "src/puppet-server", "/etc/puppet", create: true
     
  end

  config.vm.define :bareOSdirector do |srv|
      srv.vm.hostname = "bareOSdirector"
      srv.vm.network :private_network, ip: '10.0.3.10'
      srv.vm.provision "shell", inline: $puppetClientBareOSdir
  end

  config.vm.define :webserver do |srv|
      srv.vm.hostname = "webserver"
      srv.vm.network :private_network, ip: '10.0.3.8'   
      srv.vm.provision "shell", inline: $puppetClientWebserver
  end
end
