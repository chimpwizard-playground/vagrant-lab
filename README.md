# Lab

```yaml
by: иÐгü
email: ndru@chimpwizard.com
date: 10.1.2018
version: draft
```

****

One of the challenges for the developers when building scalable applications is to get an environment as close to the real production environment. The purpose of this library is to provide an easy mechanism to provision a cluster that can be use locally to test contenarized applications.

## The implementation

The lab is provisioned usig [vagrant](https://www.vagrantup.com/intro/index.html) encapsulating the complexity thru an easy to use cli.

The vagrant file:

```vagrant
# -*- mode: ruby -*-
# vi: set ft=ruby :
#^syntax detection


VAGRANTFILE_API_VERSION = "2"
Vagrant.require_version ">= 1.8.1"
ENV['VAGRANT_DEFAULT_PROVIDER'] = 'virtualbox'

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
      node.vm.box = "bento/ubuntu-16.04"

      node.vm.hostname = machine[:hostname]
      node.vm.network "private_network", ip:machine[:ip]

      node.vm.provider :virtualbox do |vb|
        vb.memory=2048  # 4096
        vb.cpus = 1     # 4
      end

      if node.vm.hostname == "console"
        node.vm.synced_folder ".", "/home/app", owner: "vagrant", group: "vagrant"
        node.vm.provision "file", source: "./scripts", destination: "$HOME/scripts"
        node.vm.provision "file", source: "./samples", destination: "$HOME/samples"
        node.vm.provision "shell", privileged:false, path:"./scripts/vagrant/setup.sh", args:["#{servers[0][:ip]}","#{ENV['PLATFORM']}"]
      end

      if node.vm.hostname != "console"
        node.vm.provision "file", source: "./scripts", destination: "$HOME/scripts"
        node.vm.provision "shell", privileged:false, path:"./scripts/vagrant/setup.sh", args:["#{servers[0][:ip]}","#{ENV['PLATFORM']}"]
      end
    end
  end

end
```

## Prerequisites to run the code

- install [npm](https://docs.npmjs.com/getting-started/what-is-npm)
- install [vagrant](https://www.vagrantup.com/intro/index.html)

## Quickstart

First you need to install the cli

```shell
npm install -g @chimpwizard/lab
```

### to start the cluster

```shell
lab up --platform [swarm|k8s]
```

### to clean up your machine

```shell
lab down
```

## Some references while doing this

- https://www.vagrantup.com/docs/provisioning/shell.html
- https://app.vagrantup.com/boxes/search
- https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/
- https://github.com/helm/charts/tree/master/stable/mysql/templates
- https://stackoverflow.com/questions/48556971/unable-to-install-kubernetes-charts-on-specified-namespace
- https://github.com/kubernetes/dashboard/wiki/Installation
- https://letsencrypt.org/getting-started/
- https://github.crookster.org/Kubernetes-Ubuntu-18.04-Bare-Metal-Single-Host/
- https://mherman.org/blog/setting-up-a-kubernetes-cluster-on-ubuntu/
- https://github.com/kubernetes/kubeadm/issues/980
- https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#master-isolation
- http://cidr.xyz
- https://www.ipaddressguide.com/cidr
- https://github.com/oracle/vagrant-boxes/blob/master/Kubernetes/Vagrantfile
- https://github.com/rootsongjc/kubernetes-vagrant-centos-cluster/blob/master/Vagrantfile
- https://stackoverflow.com/questions/14124234/how-to-pass-parameter-on-vagrant-up-and-have-it-in-the-scope-of-vagrantfile
- https://stackoverflow.com/questions/42718527/vagrant-up-command-throwing-ssl-error


## Additional improvements

- Add an additional feature to be able to specify the host OS environment

```shell
lab up --os [ubuntu|centos|debian|rhel|windows]
```






<!-- Global site tag (gtag.js) - Google Analytics -->
<script async src="https://www.googletagmanager.com/gtag/js?id=UA-43465642-1"></script>
<script>
  window.dataLayer = window.dataLayer || [];
  function gtag(){dataLayer.push(arguments);}
  gtag('js', new Date());

  gtag('config', 'UA-43465642-1');
</script>