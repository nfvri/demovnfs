#!/usr/bin/env bash

USER_NAME="nfvsap"
USER_PASSWD="nfvsap"
CLOUD_IMG_URL="https://cloud-images.ubuntu.com/releases/16.04/release"
CLOUD_IMG_NAME="ubuntu-16.04-server-cloudimg-amd64-disk1.img"
CLOUD_IMG_PATH=.
POOL=default
POOL_PATH=/var/lib/libvirt/images
#POOL=nanastop
#POOL_PATH=/store/images/demovnfs
GUEST_NAME="ip-pipeline-vm"
#GUEST_VROOTDISKSIZE=10G
GUEST_VCPUS=4
GUEST_MEM_MB=4096
GUEST_HUGEPAGES=0
GUEST_NETIF1_TYPE="bridge"
GUEST_NETIF1_BRIDGE="virbr0"
GUEST_NETIF2_TYPE="bridge"
GUEST_NETIF2_BRIDGE="virbr0"
GUEST_NETIF5_TYPE="bridge"
GUEST_NETIF5_BRIDGE="virbr0"
#GUEST_NETIF3_TYPE="vhostuser"
GUEST_NETIF3_MACADDR="00:00:00:00:00:01"
GUEST_NETIF3_UNIXPATH="/usr/local/var/run/openvswitch/dpdkvhostuser1"
GUEST_NETIF3_QUEUES=2
#GUEST_NETIF4_TYPE="vhostuser"
GUEST_NETIF4_MACADDR="00:00:00:00:00:02"
GUEST_NETIF4_UNIXPATH="/usr/local/var/run/openvswitch/dpdkvhostuser2"
GUEST_NETIF4_QUEUES=2
# guest image format: qcow2 or raw
FORMAT=qcow2
# convert image format : yes or no
CONVERT=no
