#!/bin/bash

platform=$2

echo "------------------"
echo "MASTER: $1"
echo "PLATFORM: $platform"
echo "------------------"



echo "FOLDER: $PWD"

case "$platform" in

    swarm)
        echo "SWARM"
        chmod +x /home/vagrant/scripts/vagrant/swarm/setup.sh
        /home/vagrant/scripts/vagrant/swarm/setup.sh $1
    ;;

    k8s|kubernetes)
        echo "K8s"
        chmod +x /home/vagrant/scripts/vagrant/k8s/setup.sh 
        /home/vagrant/scripts/vagrant/k8s/setup.sh $1
    ;;

    none)
        echo "NONE"
        chmod +x /home/vagrant/scripts/vagrant/none/setup.sh 
        /home/vagrant/scripts/vagrant/none/setup.sh $1
    ;;

    *)
        echo "OTHER"
        
    ;;

esac