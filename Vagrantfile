# -*- mode: ruby -*-
# vi: set ft=ruby :
#^syntax detection


VAGRANTFILE_API_VERSION = "2"
Vagrant.require_version ">= 1.8.1"
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'

require 'getoptlong'

opts = GetoptLong.new(
  [ '--script-path', GetoptLong::OPTIONAL_ARGUMENT ]
)

scriptpath=''

opts.ordering=(GetoptLong::REQUIRE_ORDER)   ### this line.


opts.each do |opt, arg|
  case opt
    when '--script-path'
      scriptpath=arg
  end
end

## puts "scriptpath: #{scriptpath}"

#
# Order matters b/c we need master kube.config on console
#
servers=[
  { :hostname => "master1", :ip => "172.10.10.20" },
  { :hostname => "console", :ip => "172.10.10.10" },
  { :hostname => "node1",   :ip => "172.10.10.30" },
  { :hostname => "node2",   :ip => "172.10.10.40" }
]

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  servers.each do |machine|
    config.vm.define machine[:hostname] do |node|
      node.vm.box_download_insecure = true #added by Amos for curl error
      node.vm.box = "bento/ubuntu-16.04"
      #node.vm.provision "docker"

      #node.vm.box = "ubuntu/xenial64"
      #node.vm.box = "centos/7"
      #node.vm.box = "debian/jessie64"
      #node.vm.box = "generic/rhel7"
      #node.vm.box = "mrlunar/windows-server-2016-containers"
      #node.vm.box = "https://cloud-images.ubuntu.com/xenial/current/xenial-server-cloudimg-amd64-vagrant.box"

      node.vm.hostname = machine[:hostname]
      node.vm.network "private_network", ip:machine[:ip]

      #Use this to make it part of the mac network
      #node.vm.network "private_network", type: "dhcp"
      
      #node.vm.box_version = "201801.02.0"

      node.vm.provider :virtualbox do |vb|
        vb.memory=2048  # 4096
        vb.cpus = 1     # 4
      end

      # if node.vm.hostname == "master"
      #   # Bind kubernetes admin port so we can administrate from host
      #   node.vm.network "forwarded_port", guest: 6443, host: 6443
      #   # Bind kubernetes default proxy port
      #   node.vm.network "forwarded_port", guest: 8001, host: 8001
      # end

      if node.vm.hostname == "console"
        node.vm.synced_folder ".", "/home/app", owner: "vagrant", group: "vagrant"
        node.vm.provision "file", source: "#{scriptpath}/scripts", destination: "$HOME/scripts"
        #node.vm.provision "file", source: "./samples", destination: "$HOME/samples"
        node.vm.provision "shell", privileged:false, path:"#{scriptpath}/scripts/vagrant/setup.sh", args:["#{servers[0][:ip]}","#{ENV['PLATFORM']}"]
      end

      if node.vm.hostname != "console"
        node.vm.provision "file", source: "#{scriptpath}/scripts", destination: "$HOME/scripts"
        node.vm.provision "shell", privileged:false, path:"#{scriptpath}/scripts/vagrant/setup.sh", args:["#{servers[0][:ip]}","#{ENV['PLATFORM']}"]
      end
    end
  end

end
