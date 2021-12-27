#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Copyright(c) 2019 Intel Corporation

#######
## Validated for clx2
#######

set -e
set -x
# TCP port of bess/web monitor
gui_port_premium=8000
bessd_port_premium=10514
metrics_port_premium=8080

gui_port_normal=8001
bessd_port_normal=10515
metrics_port_normal=8082

# Driver options. Choose any one of the three
#
# "dpdk" set as default
# "af_xdp" uses AF_XDP sockets via DPDK's vdev for pkt I/O. This version is non-zc version. ZC version still needs to be evaluated.
# "af_packet" uses AF_PACKET sockets via DPDK's vdev for pkt I/O.
# "sim" uses Source() modules to simulate traffic generation
#mode="dpdk"
#mode="af_xdp"
mode="af_packet"
#mode="sim"

# Gateway interface(s)
#
# In the order of ("s1u" "sgi")
ifaces=("ens801f0" "ens801f1")

# Static IP addresses of gateway interface(s) in cidr format
#
# In the order of (s1u sgi)
ipaddrs=(198.19.0.1/30 198.18.0.1/30)

# MAC addresses of gateway interface(s)
#
# In the order of (s1u sgi)
macaddrs_premium=(9e:b2:d3:34:ab:28 c2:9c:55:d4:8a:f8)
macaddrs_normal=(be:b2:d3:34:ab:28 d2:9c:55:d4:8a:f8)

# Static IP addresses of the neighbors of gateway interface(s)
#
# In the order of (n-s1u n-sgi)
nhipaddrs=(198.19.0.2 198.18.0.2)

# Static MAC addresses of the neighbors of gateway interface(s)
#
# In the order of (n-s1u n-sgi)
nhmacaddrs=(22:53:7a:15:58:51 22:53:7a:15:58:51)

# IPv4 route table entries in cidr format per port
#
# In the order of ("{r-s1u}" "{r-sgi}")
routes=("0.0.0.0/0" "11.1.1.128/25")

num_ifaces=${#ifaces[@]}
num_ipaddrs=${#ipaddrs[@]}

# Set up static route and neighbor table entries of the SPGW
function setup_trafficgen_routes() {
        for ((i = 0; i < num_ipaddrs; i++)); do
                #sudo ip netns exec pause ip neighbor add "${nhipaddrs[$i]}" lladdr "${nhmacaddrs[$i]}" dev "${ifaces[$i % num_ifaces]}"
		sudo ip neighbor add "${nhipaddrs[$i]}" lladdr "${nhmacaddrs[$i]}" dev "${ifaces[$i % num_ifaces]}" || true
                routelist=${routes[$i]}
                for route in $routelist; do
                        #sudo ip netns exec pause ip route add "$route" via "${nhipaddrs[$i]}" metric 100
			sudo ip route add "$route" via "${nhipaddrs[$i]}" metric 100 || true
                done
        done
}

# Assign IP address(es) of gateway interface(s) within the network namespace
function setup_addrs() {
        for ((i = 0; i < num_ipaddrs; i++)); do
                #sudo ip netns exec pause ip addr add "${ipaddrs[$i]}" dev "${ifaces[$i % $num_ifaces]}"
		sudo ip addr add "${ipaddrs[$i]}" dev "${ifaces[$i % $num_ifaces]}" || true
        done
}

# Set up mirror links to communicate with the kernel
#
# These vdev interfaces are used for ARP + ICMP updates.
# ARP/ICMP requests are sent via the vdev interface to the kernel.
# ARP/ICMP responses are captured and relayed out of the dpdk ports.
function setup_mirror_links() {
        #for ((i = 0; i < num_ifaces; i++)); do
                #sudo ip netns exec pause ip link add "${ifaces[$i]}" type veth peer name "${ifaces[$i]}"-vdev
                #sudo ip netns exec pause ip link set "${ifaces[$i]}" up
                #sudo ip netns exec pause ip link set "${ifaces[$i]}-vdev" up
                #sudo ip netns exec pause ip link set dev "${ifaces[$i]}" address "${macaddrs[$i]}"
        #done
        setup_addrs
}

# Set up interfaces in the network namespace. For non-"dpdk" mode(s)
function move_ifaces() {
        for ((i = 0; i < num_ifaces; i++)); do
                #sudo ip link set "${ifaces[$i]}" netns pause up
                #sudo ip netns exec pause ip link set "${ifaces[$i]}" promisc off
                #sudo ip netns exec pause ip link set "${ifaces[$i]}" xdp off
		sudo ip link set "${ifaces[$i]}" up
		sudo ip link set dev "${ifaces[$i]}" vf 0 mac "${macaddrs_premium[$i]}"
		sudo ip link set dev "${ifaces[$i]}" vf 1 mac "${macaddrs_normal[$i]}"
		sudo ip link set "${ifaces[$i]}" promisc on
		#sudo ip link set "${ifaces[$i]}" xdp off
		sudo ip link set "${ifaces[$i]}" vf 0 state enable trust on spoof off promisc on
		sudo ip link set "${ifaces[$i]}" vf 1 state enable trust on spoof off promisc on
                #if [ "$mode" == 'af_xdp' ]; then
                #        sudo ip netns exec pause ethtool --features "${ifaces[$i]}" ntuple off
                #        sudo ip netns exec pause ethtool --features "${ifaces[$i]}" ntuple on
                #        sudo ip netns exec pause ethtool -N "${ifaces[$i]}" flow-type udp4 action 0
                #        sudo ip netns exec pause ethtool -N "${ifaces[$i]}" flow-type tcp4 action 0
                #        sudo ip netns exec pause ethtool -u "${ifaces[$i]}"
                #fi
        done
        setup_addrs
}

# Stop previous instances of bess* before restarting
docker stop pause premium-bess normal-bess routectl-premium-bess routectl-normal-bess web-premium-bess \
	web-normal-bess pfcpiface-premium-bess pfcpiface-normal-bess || true
docker rm -f pause premium-bess normal-bess routectl-premium-bess routectl-normal-bess web-premium-bess \
	web-normal-bess pfcpiface-premium-bess pfcpiface-normal-bess || true
sudo rm -rf /var/run/netns/pause

# Build
#make docker-build

if [ "$mode" == 'dpdk' ]; then
        DEVICES=${DEVICES:-'--device=/dev/vfio/154 --device=/dev/vfio/158 --device=/dev/vfio/vfio'}
        PRIVS='--cap-add IPC_LOCK'

elif [ "$mode" == 'af_xdp' ]; then
        PRIVS='--privileged'

elif [ "$mode" == 'af_packet' ]; then
	DEVICES_PREMIUM=${DEVICES_PREMIUM:-'--device=/dev/vfio/311 --device=/dev/vfio/319 --device=/dev/vfio/vfio'}
	DEVICES_NORMAL=${DEVICES_NORMAL:-'--device=/dev/vfio/312 --device=/dev/vfio/320 --device=/dev/vfio/vfio'}
        PRIVS='--cap-add IPC_LOCK'
fi

# Run pause
#docker run --name pause -td --restart unless-stopped \
#        -p $bessd_port_premium:$bessd_port_premium \
#	-p $bessd_port_normal:$bessd_port_normal \
#        -p $gui_port_premium:$gui_port_premium \
#	-p $gui_port_normal:$gui_port_normal \
#        -p $metrics_port_premium:$metrics_port_premium \
#	-p $metrics_port_normal:$metrics_port_normal \
#        --hostname $(hostname) \
#        k8s.gcr.io/pause

# Emulate CNI + init container
#sudo mkdir -p /var/run/netns
#sandbox=$(docker inspect --format='{{.NetworkSettings.SandboxKey}}' pause)
#sudo ln -s "$sandbox" /var/run/netns/pause

case $mode in
"dpdk" | "sim") setup_mirror_links ;;
"af_xdp" | "af_packet")
        move_ifaces
        # Make sure that kernel does not send back icmp dest unreachable msg(s)
        #sudo ip netns exec pause iptables -I OUTPUT -p icmp --icmp-type port-unreachable -j DROP
	sudo iptables -I OUTPUT -p icmp --icmp-type port-unreachable -j DROP
        ;;
*) ;;

esac

# Setup trafficgen routes
if [ "$mode" != 'sim' ]; then
        setup_trafficgen_routes
fi

# Run bessd
# --cpuset-cpus=2,50,4,52,6,54,8,56,10,58,12,60,14,62
docker run --name premium-bess -td --restart unless-stopped \
        --cpuset-cpus=32-45,96-109 \
        --ulimit memlock=-1 -v /dev/hugepages:/dev/hugepages \
        -v "$PWD/conf":/opt/bess/bessctl/conf \
	--network host \
        $PRIVS \
        $DEVICES_PREMIUM \
	ghcr.io/omec-project/upf-epc/upf-epc-bess:0.3.0-dev -grpc-url=0.0.0.0:$bessd_port_premium


docker logs premium-bess

# --cpuset-cpus=16,64,18,66,20,68,22,70,24,72,26,74,28,76
docker run --name normal-bess -td --restart unless-stopped \
        --cpuset-cpus=48-61,112-125 \
        --ulimit memlock=-1 -v /dev/hugepages:/dev/hugepages \
        -v "$PWD/conf":/opt/bess/bessctl/conf \
        --network host \
        $PRIVS \
        $DEVICES_NORMAL \
        upf-epc-8806-bess:0.3.0-dev -grpc-url=0.0.0.0:$bessd_port_normal

docker logs normal-bess

# Sleep for a couple of secs before setting up the pipeline
sleep 40
docker exec premium-bess ./bessctl run up4_premium_ilx1
docker exec normal-bess ./bessctl daemon disconnect -- daemon connect localhost:$bessd_port_normal -- run up4_normal_ilx1
sleep 20

# Run web-bess
docker run --name web-premium-bess -d --restart unless-stopped \
        --net container:premium-bess \
        --entrypoint bessctl \
	ghcr.io/omec-project/upf-epc/upf-epc-bess:0.3.0-dev http 0.0.0.0 $gui_port_premium


docker run --name web-normal-bess -d --restart unless-stopped \
        --net container:normal-bess \
	--entrypoint "" \
        upf-epc-8806-bess:0.3.0-dev bessctl daemon disconnect -- daemon connect localhost:$bessd_port_normal -- http 0.0.0.0 $gui_port_normal

# Run pfcpiface-bess depending on mode type
docker run --name pfcpiface-premium-bess -td --restart on-failure \
	--network host \
        -v "$PWD/conf/upf_premium_ilx1.json":/conf/upf_premium_ilx1.json \
	ghcr.io/omec-project/upf-epc/upf-epc-pfcpiface:0.3.0-dev \
        -config /conf/upf_premium_ilx1.json


docker run --name pfcpiface-normal-bess -td --restart on-failure \
	--network host \
        -v "$PWD/conf/upf_normal_ilx1.json":/conf/upf_normal_ilx1.json \
        upf-epc-8806-pfcpiface:0.3.0-dev \
        -config /conf/upf_normal_ilx1.json -bess localhost:$bessd_port_normal -http 0.0.0.0:$metrics_port_normal

# To add rules:
# docker exec pfcpiface-premium-bess pfcpiface -config /conf/upf_premium_ilx1.json -simulate create
# docker exec pfcpiface-normal-bess pfcpiface -config /conf/upf_normal_ilx1.json -bess localhost:$bessd_port_normal -simulate create

# Don't run any other container if mode is "sim"
if [ "$mode" == 'sim' ]; then
        exit
fi

# Run routectl-bess
docker run --name routectl-premium-bess -td --restart unless-stopped \
	--network host \
        -v "$PWD/conf/route_control_premium.py":/route_control_premium.py \
        --pid container:premium-bess \
        --entrypoint /route_control_premium.py \
	ghcr.io/omec-project/upf-epc/upf-epc-bess:0.3.0-dev -i "${ifaces[@]}"


docker run --name routectl-normal-bess -td --restart unless-stopped \
	--network host \
        -v "$PWD/conf/route_control_normal.py":/route_control_normal.py \
        --pid container:normal-bess \
        --entrypoint /route_control_normal.py \
        upf-epc-8806-bess:0.3.0-dev --port $bessd_port_normal -i "${ifaces[@]}"
