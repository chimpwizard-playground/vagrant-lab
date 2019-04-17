#!/bin/bash
echo "---------------------------------------------------------------------"
echo "PARAMS: "
echo "   IP: $1"
echo "---------------------------------------------------------------------"


echo "---------------------------------------------------------------------"
echo "Update system"
echo "---------------------------------------------------------------------"
sudo apt-get update
 
echo "---------------------------------------------------------------------"
echo "Installing dependencies"
echo "---------------------------------------------------------------------"

sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common




echo "---------------------------------------------------------------------"
echo "Installing docker"
echo "---------------------------------------------------------------------"

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo apt-key fingerprint 0EBFCD88

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get install -y docker.io



echo "---------------------------------------------------------------------"
echo "Give docekr access to vagrant"
echo "---------------------------------------------------------------------"
sudo usermod -aG docker vagrant

sudo chmod 777 /var/run/docker.sock


# echo "---------------------------------------------------------------------"
# echo "Install kubeadmin"
# echo "---------------------------------------------------------------------"
# sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
# sudo echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > ./tmp
# sudo cp ./tmp /etc/apt/sources.list.d/kubernetes.list
# sudo apt-get update

# #sudo apt-get install -qy kubelet=1.10.0 kubeadm=1.10.0 kubectl=1.10.0 kubernetes-cni=0.6.0
# #sudo apt install -y kubeadm  kubelet kubectl kubernetes-cni
# sudo apt-get install -y kubelet=1.9.0-00 kubeadm=1.9.0-00 kubectl=1.9.0-00

# #sudo apt install -y kubelet=1.8.4-00 kubernetes-cni=0.5.1-00 kubectl=1.8.4-00 kubeadm=1.8.4-00

echo "---------------------------------------------------------------------"
echo "Set host name resolution"
echo "---------------------------------------------------------------------"

#
# This is important to be able to connect to the pods otherwise you will see
# resource not found
#
echo 'set host name resolution'
cp /etc/hosts /tmp/hosts
sudo echo  '''
172.10.10.20 master1
172.10.10.30 node1
172.10.10.40 node2
'''>> /tmp/hosts
sudo cp /tmp/hosts /etc/hosts
cat /etc/hosts


if [[ "$HOSTNAME" == master* ]]
then

 #When the network is private and type=dhcp
 #IPADDR=`ifconfig enp0s8 | grep Mask | awk '{print $2}'| cut -f2 -d:` 
 IPADDR=$(hostname -i)
 NODENAME=$(hostname -s)


 echo "---------------------------------------------------------------------"
 echo "Configure Kubernetes ( node: ${NODENAME} ) and Init Cluster @ $1 IPADDR=${IPADDR}"
 echo "---------------------------------------------------------------------"

 curl -sfL https://get.k3s.io | sudo sh -
 sudo cp /var/lib/rancher/k3s/server/node-token /vagrant/node-token


 echo "---------------------------------------------------------------------"
 echo "Copy kube.config to to vagrant home"
 echo "---------------------------------------------------------------------"

 mkdir -p /home/vagrant/.kube
 sudo cp /etc/rancher/k3s/k3s.yaml /home/vagrant/.kube/config
 sudo chown vagrant:vagrant /home/vagrant/.kube/config
 sudo cp /etc/rancher/k3s/k3s.yaml /vagrant/kube.config
 sudo chmod 777 /vagrant/kube.config

#  echo "---------------------------------------------------------------------"
#  echo "Allow run PODs on master"
#  echo "---------------------------------------------------------------------"
#  sudo kubectl taint nodes --all node-role.kubernetes.io/master-
#  echo "*** CHECK TAINTS"
#  sudo kubectl get no -o yaml | grep taint -A 5


 sudo kubectl get pods --all-namespaces



 echo "---------------------------------------------------------------------"
 echo "Show Nodes"
 echo "---------------------------------------------------------------------"
 kubectl --kubeconfig .kube/config get nodes

fi

if [[ "$HOSTNAME" == node* ]]
then
 sudo chmod 777 /var/run/docker.sock

 echo "---------------------------------------------------------------------"
 echo "Join cluster"
 echo "---------------------------------------------------------------------"
 curl -sfL https://get.k3s.io | sudo K3S_TOKEN=`cat /vagrant/node-token`  K3S_URL=https://master1:6443 sh -

fi

if [[ "$HOSTNAME" == console* ]]
then


 #Install docker compose and start weave scope
 echo "---------------------------------------------------------------------"
 echo "Installing docker compose"
 echo "---------------------------------------------------------------------"
 #sudo apt install -y docker-compose
 export DOCKER_COMPOSE_VERSION=1.13.0
 sudo curl --insecure -L https://github.com/docker/compose/releases/download/$DOCKER_COMPOSE_VERSION/docker-compose-`uname -s`-`uname -m` > ./dc
 sudo cp ./dc //usr/local/bin/docker-compose 
 sudo chmod +x /usr/local/bin/docker-compose

 #Install developer tools
 echo "---------------------------------------------------------------------"
 echo "Installing developer tools"
 echo "---------------------------------------------------------------------"
 sudo apt-get install -y git
 curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
 sudo apt-get install -y nodejs
 sudo apt-get install -y build-essential
 sudo apt-get install -y npm
 sudo npm install npm --global
 sudo apt-get install dos2unix

echo "---------------------------------------------------------------------"
echo "Install kubeadmin"
echo "---------------------------------------------------------------------"
sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
sudo echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" > ./tmp
sudo cp ./tmp /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl=1.9.0-00

 echo "---------------------------------------------------------------------"
 echo "Use kube.config for configuration"
 echo "---------------------------------------------------------------------"
 #no need to copy since there is already a mapping to /home/app
 sudo mkdir -p /home/vagrant/.kube
 sudo chown vagrant:vagrant /home/vagrant/.kube
 ##sudo cp /vagrant/kube.config /home/vagrant/.kube/config
 sudo cp /home/app/kube.config /home/vagrant/.kube/config
 sudo chown vagrant:vagrant /home/vagrant/.kube/config
 #sudo chown vagrant:vagrant $HOME/.kube/config
 sudo sed -i 's/localhost/master1/g' /home/vagrant/.kube/config
 sudo echo "export KUBECONFIG=/home/vagrant/.kube/config" >> /home/vagrant/.bashrc


echo "---------------------------------------------------------------------"
echo "Install snap and helm"
echo "---------------------------------------------------------------------"
sudo apt install -y snapd
sudo snap install helm --classic
#curl https://raw.githubusercontent.com/helm/helm/master/scripts/get | sudo -

fi

echo "---------------------------------------------------------------------"
echo "DONE $HOSTNAME"
echo "---------------------------------------------------------------------"


