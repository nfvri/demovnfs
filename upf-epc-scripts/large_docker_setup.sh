#!/usr/bin/env bash
# SPDX-License-Identifier: Apache-2.0
# Copyright(c) 2019 Intel Corporation

set -e
set -x
# TCP port of bess/web monitor
gui_port_premium_1=8000
bessd_port_premium_1=10514
metrics_port_premium_1=8080

gui_port_premium_2=8001
bessd_port_premium_2=10515
metrics_port_premium_2=8081

gui_port_normal_1=8002
bessd_port_normal_1=10516
metrics_port_normal_1=8082

gui_port_normal_2=8003
bessd_port_normal_2=10517
metrics_port_normal_2=8083

gui_port_premium_3=8004
bessd_port_premium_3=10518
metrics_port_premium_3=8084

gui_port_premium_4=8005
bessd_port_premium_4=10519
metrics_port_premium_4=8085

gui_port_normal_3=8006
bessd_port_normal_3=10520
metrics_port_normal_3=8086

gui_port_normal_4=8007
bessd_port_normal_4=10521
metrics_port_normal_4=8087
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
ifaces=("ens66f0" "ens66f1" "ens75f0" "ens75f1")

# Static IP addresses of gateway interface(s) in cidr format
#
# In the order of (s1u sgi)
ipaddrs=(198.18.0.1/30 198.19.0.1/30 198.28.0.1/30 198.29.0.1/30)

dummy_ipaddrs=(198.20.0.1/30 198.21.0.1/30 198.22.0.1/30 198.23.0.1/30 198.24.0.1/30 198.25.0.1/30 198.26.0.1/30 198.27.0.1/30)

# MAC addresses of gateway interface(s)
#
# In the order of (s1u sgi)
macaddrs_premium_1=(9e:b2:d3:34:ab:27 c2:9c:55:d4:8a:f6)
macaddrs_premium_2=(9e:b2:d3:34:ab:37 c2:9c:55:d4:8a:f8)
macaddrs_normal_1=(9e:b2:d3:34:ab:47 c2:9c:55:d4:8a:fa)
macaddrs_normal_2=(9e:b2:d3:34:ab:57 c2:9c:55:d4:8a:fb)
macaddrs_premium_3=(ae:b2:d3:34:ab:27 d2:9c:55:d4:8a:f6)
macaddrs_premium_4=(ae:b2:d3:34:ab:37 d2:9c:55:d4:8a:f8)
macaddrs_normal_3=(ae:b2:d3:34:ab:47 d2:9c:55:d4:8a:fa)
macaddrs_normal_4=(ae:b2:d3:34:ab:57 d2:9c:55:d4:8a:fb)

# Static IP addresses of the neighbors of gateway interface(s)
#
# In the order of (n-s1u n-sgi)
nhipaddrs=(198.18.0.2 198.19.0.2)

# Static MAC addresses of the neighbors of gateway interface(s)
#
# In the order of (n-s1u n-sgi)
nhmacaddrs=(22:53:7a:15:58:50 22:53:7a:15:58:50)

# IPv4 route table entries in cidr format per port
#
# In the order of ("{r-s1u}" "{r-sgi}")
routes=("11.1.1.128/25" "0.0.0.0/0")

num_ifaces=${#ifaces[@]}
num_ipaddrs=${#ipaddrs[@]}
num_dummy_ipaddrs=${#dummy_ipaddrs[@]}

# Set up static route and neighbor table entries of the SPGW
function setup_trafficgen_routes() {
	k=101
	z=0
        for ((i = 0; i < num_ipaddrs; i++)); do
		if [ $z -gt 1 ]
		then z=0
		fi
                #sudo ip netns exec pause ip neighbor add "${nhipaddrs[$i]}" lladdr "${nhmacaddrs[$i]}" dev "${ifaces[$i % num_ifaces]}"
		sudo ip neighbor add "${nhipaddrs[$z]}" lladdr "${nhmacaddrs[$z]}" dev "${ifaces[$i % num_ifaces]}" || true
                routelist=${routes[$z]}
                for route in $routelist; do
                        #sudo ip netns exec pause ip route add "$route" via "${nhipaddrs[$i]}" metric 100
			sudo ip route add "$route" via "${nhipaddrs[$z]}" metric $k || true
			k=$(($k+1))
                done
		z=$(($z+1))
        done
}

# Assign IP address(es) of gateway interface(s) within the network namespace
function setup_addrs() {
        for ((i = 0; i < num_ipaddrs; i++)); do
		sudo ip addr add "${ipaddrs[$i]}" dev "${ifaces[$i % $num_ifaces]}" || true
        done
        for ((i = 0; i < num_dummy_ipaddrs; i++)); do
		sudo ip addr add "${dummy_ipaddrs[$i]}" dev ens12f1  || true
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
        for ((i = 0; i < 2; i++)); do
                #sudo ip link set "${ifaces[$i]}" netns pause up
                #sudo ip netns exec pause ip link set "${ifaces[$i]}" promisc off
                #sudo ip netns exec pause ip link set "${ifaces[$i]}" xdp off
		sudo ip link set "${ifaces[$i]}" up
		sudo ip link set dev "${ifaces[$i]}" vf 0 mac "${macaddrs_premium_1[$i]}"
		sudo ip link set dev "${ifaces[$i]}" vf 1 mac "${macaddrs_premium_2[$i]}"
		sudo ip link set dev "${ifaces[$i]}" vf 2 mac "${macaddrs_normal_1[$i]}"
		sudo ip link set dev "${ifaces[$i]}" vf 3 mac "${macaddrs_normal_2[$i]}"
		sudo ip link set "${ifaces[$i]}" promisc on
		sudo ip link set "${ifaces[$i]}" xdp off
                #if [ "$mode" == 'af_xdp' ]; then
                #        sudo ip netns exec pause ethtool --features "${ifaces[$i]}" ntuple off
                #        sudo ip netns exec pause ethtool --features "${ifaces[$i]}" ntuple on
                #        sudo ip netns exec pause ethtool -N "${ifaces[$i]}" flow-type udp4 action 0
                #        sudo ip netns exec pause ethtool -N "${ifaces[$i]}" flow-type tcp4 action 0
                #        sudo ip netns exec pause ethtool -u "${ifaces[$i]}"
                #fi
        done
        for ((i = 2; i < 4; i++)); do
		sudo ip link set "${ifaces[$i]}" up
		sudo ip link set dev "${ifaces[$i]}" vf 0 mac "${macaddrs_premium_3[$((i-2))]}"
		sudo ip link set dev "${ifaces[$i]}" vf 1 mac "${macaddrs_premium_4[$((i-2))]}"
		sudo ip link set dev "${ifaces[$i]}" vf 2 mac "${macaddrs_normal_3[$((i-2))]}"
		sudo ip link set dev "${ifaces[$i]}" vf 3 mac "${macaddrs_normal_4[$((i-2))]}"
		sudo ip link set "${ifaces[$i]}" promisc on
		sudo ip link set "${ifaces[$i]}" xdp off
        done
        setup_addrs
}

#docker stop pause
#docker rm -f pause
for i in "1" "2" "3" "4";
do
docker stop premium-bess-${i} normal-bess-${i} routectl-premium-bess-${i} routectl-normal-bess-${i} web-premium-bess-${i} \
	web-normal-bess-${i} pfcpiface-premium-bess-${i} pfcpiface-normal-bess-${i} || true
docker rm -f premium-bess-${i} normal-bess-${i} routectl-premium-bess-${i} routectl-normal-bess-${i} web-premium-bess-${i} \
	web-normal-bess-${i} pfcpiface-premium-bess-${i} pfcpiface-normal-bess-${i} || true
done
# Stop previous instances of bess* before restarting
#docker stop pause premium-bess-1 normal-bess-1 routectl-premium-bess-1 routectl-normal-bess-1 web-premium-bess-1 \
#	web-normal-bess-1 pfcpiface-premium-bess-1 pfcpiface-normal-bess-1 || true
#docker rm -f pause premium-bess-1 normal-bess-1 routectl-premium-bess-1 routectl-normal-bess-1 web-premium-bess-1 \
#	web-normal-bess-1 pfcpiface-premium-bess-1 pfcpiface-normal-bess-1 || true
sudo rm -rf /var/run/netns/pause

# Build
#make docker-build

if [ "$mode" == 'dpdk' ]; then
        DEVICES=${DEVICES:-'--device=/dev/vfio/154 --device=/dev/vfio/158 --device=/dev/vfio/vfio'}
        PRIVS='--cap-add IPC_LOCK'

elif [ "$mode" == 'af_xdp' ]; then
        PRIVS='--privileged'

elif [ "$mode" == 'af_packet' ]; then
	DEVICES_PREMIUM_1=${DEVICES_PREMIUM_1:-'--device=/dev/vfio/467 --device=/dev/vfio/475 --device=/dev/vfio/vfio'}
	DEVICES_PREMIUM_2=${DEVICES_PREMIUM_2:-'--device=/dev/vfio/468 --device=/dev/vfio/476 --device=/dev/vfio/vfio'}
	DEVICES_NORMAL_1=${DEVICES_NORMAL_1:-'--device=/dev/vfio/469 --device=/dev/vfio/477 --device=/dev/vfio/vfio'}
	DEVICES_NORMAL_2=${DEVICES_NORMAL_2:-'--device=/dev/vfio/470 --device=/dev/vfio/478 --device=/dev/vfio/vfio'}
	DEVICES_PREMIUM_3=${DEVICES_PREMIUM_3:-'--device=/dev/vfio/483 --device=/dev/vfio/491 --device=/dev/vfio/vfio'}
	DEVICES_PREMIUM_4=${DEVICES_PREMIUM_4:-'--device=/dev/vfio/484 --device=/dev/vfio/492 --device=/dev/vfio/vfio'}
	DEVICES_NORMAL_3=${DEVICES_NORMAL_3:-'--device=/dev/vfio/485 --device=/dev/vfio/493 --device=/dev/vfio/vfio'}
	DEVICES_NORMAL_4=${DEVICES_NORMAL_4:-'--device=/dev/vfio/486 --device=/dev/vfio/494 --device=/dev/vfio/vfio'}
        PRIVS='--cap-add IPC_LOCK'
fi


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
docker run --name premium-bess-1 -td --restart unless-stopped \
        --cpuset-cpus=0-12 \
        --ulimit memlock=-1 -v /dev/hugepages:/dev/hugepages \
        -v "$PWD/conf":/opt/bess/bessctl/conf \
	-v /tmp:/tmp \
	--network host \
        $PRIVS \
        $DEVICES_PREMIUM_1 \
	nfvri/upf-epc-bess:0.3.0-dev -grpc-url=0.0.0.0:$bessd_port_premium_1

docker run --name premium-bess-2 -td --restart unless-stopped \
        --cpuset-cpus=13-25 \
        --ulimit memlock=-1 -v /dev/hugepages:/dev/hugepages \
        -v "$PWD/conf":/opt/bess/bessctl/conf \
	-v /tmp:/tmp \
        --network host \
        $PRIVS \
        $DEVICES_PREMIUM_2 \
        nfvri/upf-epc-bess:0.3.0-dev -grpc-url=0.0.0.0:$bessd_port_premium_2

docker run --name premium-bess-3 -td --restart unless-stopped \
        --cpuset-cpus=52-64 \
        --ulimit memlock=-1 -v /dev/hugepages:/dev/hugepages \
        -v "$PWD/conf":/opt/bess/bessctl/conf \
	-v /tmp:/tmp \
        --network host \
        $PRIVS \
        $DEVICES_PREMIUM_3 \
        nfvri/upf-epc-bess:0.3.0-dev -grpc-url=0.0.0.0:$bessd_port_premium_3

docker run --name premium-bess-4 -td --restart unless-stopped \
        --cpuset-cpus=65-77 \
        --ulimit memlock=-1 -v /dev/hugepages:/dev/hugepages \
        -v "$PWD/conf":/opt/bess/bessctl/conf \
	-v /tmp:/tmp \
        --network host \
        $PRIVS \
        $DEVICES_PREMIUM_4 \
        nfvri/upf-epc-bess:0.3.0-dev -grpc-url=0.0.0.0:$bessd_port_premium_4


docker run --name normal-bess-1 -td --restart unless-stopped \
        --cpuset-cpus=26-38 \
        --ulimit memlock=-1 -v /dev/hugepages:/dev/hugepages \
        -v "$PWD/conf":/opt/bess/bessctl/conf \
	-v /tmp:/tmp \
        --network host \
        $PRIVS \
        $DEVICES_NORMAL_1 \
        nfvri/upf-epc-bess:0.3.0-dev -grpc-url=0.0.0.0:$bessd_port_normal_1

docker run --name normal-bess-2 -td --restart unless-stopped \
        --cpuset-cpus=39-51 \
        --ulimit memlock=-1 -v /dev/hugepages:/dev/hugepages \
        -v "$PWD/conf":/opt/bess/bessctl/conf \
	-v /tmp:/tmp \
        --network host \
        $PRIVS \
        $DEVICES_NORMAL_2 \
        nfvri/upf-epc-bess:0.3.0-dev -grpc-url=0.0.0.0:$bessd_port_normal_2

docker run --name normal-bess-3 -td --restart unless-stopped \
        --cpuset-cpus=78-90 \
        --ulimit memlock=-1 -v /dev/hugepages:/dev/hugepages \
        -v "$PWD/conf":/opt/bess/bessctl/conf \
	-v /tmp:/tmp \
        --network host \
        $PRIVS \
        $DEVICES_NORMAL_3 \
        nfvri/upf-epc-bess:0.3.0-dev -grpc-url=0.0.0.0:$bessd_port_normal_3

docker run --name normal-bess-4 -td --restart unless-stopped \
        --cpuset-cpus=91-103 \
        --ulimit memlock=-1 -v /dev/hugepages:/dev/hugepages \
        -v "$PWD/conf":/opt/bess/bessctl/conf \
	-v /tmp:/tmp \
        --network host \
        $PRIVS \
        $DEVICES_NORMAL_4 \
        nfvri/upf-epc-bess:0.3.0-dev -grpc-url=0.0.0.0:$bessd_port_normal_4

# Sleep for a couple of secs before setting up the pipeline
sleep 180
docker exec premium-bess-1 ./bessctl daemon disconnect -- daemon connect localhost:$bessd_port_premium_1 -- run up4_premium_1
sleep 5
docker exec premium-bess-2 ./bessctl daemon disconnect -- daemon connect localhost:$bessd_port_premium_2 -- run up4_premium_2
sleep 5
docker exec premium-bess-3 ./bessctl daemon disconnect -- daemon connect localhost:$bessd_port_premium_3 -- run up4_premium_3
sleep 5
docker exec premium-bess-4 ./bessctl daemon disconnect -- daemon connect localhost:$bessd_port_premium_4 -- run up4_premium_4
sleep 5
docker exec normal-bess-1 ./bessctl daemon disconnect -- daemon connect localhost:$bessd_port_normal_1 -- run up4_normal_1
sleep 5
docker exec normal-bess-2 ./bessctl daemon disconnect -- daemon connect localhost:$bessd_port_normal_2 -- run up4_normal_2
sleep 5
docker exec normal-bess-3 ./bessctl daemon disconnect -- daemon connect localhost:$bessd_port_normal_3 -- run up4_normal_3
sleep 5
docker exec normal-bess-4 ./bessctl daemon disconnect -- daemon connect localhost:$bessd_port_normal_4 -- run up4_normal_4
sleep 40

# Run web-bess
docker run --name web-premium-bess-1 -d --restart unless-stopped \
        --net container:premium-bess-1 \
        --entrypoint bessctl \
	nfvri/upf-epc-bess:0.3.0-dev http 0.0.0.0 $gui_port_premium_1


docker run --name web-premium-bess-2 -d --restart unless-stopped \
        --net container:premium-bess-2 \
	--entrypoint "" \
        nfvri/upf-epc-bess:0.3.0-dev bessctl daemon disconnect -- daemon connect localhost:$bessd_port_premium_2 -- http 0.0.0.0 $gui_port_premium_2

docker run --name web-premium-bess-3 -d --restart unless-stopped \
        --net container:premium-bess-3 \
	--entrypoint "" \
        nfvri/upf-epc-bess:0.3.0-dev bessctl daemon disconnect -- daemon connect localhost:$bessd_port_premium_3 -- http 0.0.0.0 $gui_port_premium_3

docker run --name web-premium-bess-4 -d --restart unless-stopped \
        --net container:premium-bess-4 \
	--entrypoint "" \
        nfvri/upf-epc-bess:0.3.0-dev bessctl daemon disconnect -- daemon connect localhost:$bessd_port_premium_4 -- http 0.0.0.0 $gui_port_premium_4

docker run --name web-normal-bess-1 -d --restart unless-stopped \
        --net container:normal-bess-1 \
	--entrypoint "" \
        nfvri/upf-epc-bess:0.3.0-dev bessctl daemon disconnect -- daemon connect localhost:$bessd_port_normal_1 -- http 0.0.0.0 $gui_port_normal_1

docker run --name web-normal-bess-2 -d --restart unless-stopped \
        --net container:normal-bess-2 \
	--entrypoint "" \
        nfvri/upf-epc-bess:0.3.0-dev bessctl daemon disconnect -- daemon connect localhost:$bessd_port_normal_2 -- http 0.0.0.0 $gui_port_normal_2

docker run --name web-normal-bess-3 -d --restart unless-stopped \
        --net container:normal-bess-3 \
	--entrypoint "" \
        nfvri/upf-epc-bess:0.3.0-dev bessctl daemon disconnect -- daemon connect localhost:$bessd_port_normal_3 -- http 0.0.0.0 $gui_port_normal_3

docker run --name web-normal-bess-4 -d --restart unless-stopped \
        --net container:normal-bess-4 \
	--entrypoint "" \
        nfvri/upf-epc-bess:0.3.0-dev bessctl daemon disconnect -- daemon connect localhost:$bessd_port_normal_4 -- http 0.0.0.0 $gui_port_normal_4

# Run pfcpiface-bess depending on mode type
docker run --name pfcpiface-premium-bess-1 -td --restart on-failure \
	--network host \
	-v /tmp:/tmp \
        -v "$PWD/conf/upf_premium_1.json":/conf/upf_premium_1.json \
	nfvri/upf-epc-pfcpiface:0.3.0-dev \
        -config /conf/upf_premium_1.json -bess localhost:$bessd_port_premium_1 -http 0.0.0.0:$metrics_port_premium_2 

docker run --name pfcpiface-premium-bess-2 -td --restart on-failure \
	--network host \
	-v /tmp:/tmp \
        -v "$PWD/conf/upf_premium_2.json":/conf/upf_premium_2.json \
        nfvri/upf-epc-pfcpiface:0.3.0-dev \
        -config /conf/upf_premium_2.json -bess localhost:$bessd_port_premium_2 -http 0.0.0.0:$metrics_port_premium_2

docker run --name pfcpiface-premium-bess-3 -td --restart on-failure \
	--network host \
	-v /tmp:/tmp \
        -v "$PWD/conf/upf_premium_3.json":/conf/upf_premium_3.json \
        nfvri/upf-epc-pfcpiface:0.3.0-dev \
        -config /conf/upf_premium_3.json -bess localhost:$bessd_port_premium_3 -http 0.0.0.0:$metrics_port_premium_3

docker run --name pfcpiface-premium-bess-4 -td --restart on-failure \
	--network host \
	-v /tmp:/tmp \
        -v "$PWD/conf/upf_premium_4.json":/conf/upf_premium_4.json \
        nfvri/upf-epc-pfcpiface:0.3.0-dev \
        -config /conf/upf_premium_4.json -bess localhost:$bessd_port_premium_4 -http 0.0.0.0:$metrics_port_premium_4

docker run --name pfcpiface-normal-bess-1 -td --restart on-failure \
	--network host \
	-v /tmp:/tmp \
        -v "$PWD/conf/upf_normal_1.json":/conf/upf_normal_1.json \
        nfvri/upf-epc-pfcpiface:0.3.0-dev \
        -config /conf/upf_normal_1.json -bess localhost:$bessd_port_normal_1 -http 0.0.0.0:$metrics_port_normal_1

docker run --name pfcpiface-normal-bess-2 -td --restart on-failure \
	--network host \
	-v /tmp:/tmp \
        -v "$PWD/conf/upf_normal_2.json":/conf/upf_normal_2.json \
        nfvri/upf-epc-pfcpiface:0.3.0-dev \
        -config /conf/upf_normal_2.json -bess localhost:$bessd_port_normal_2 -http 0.0.0.0:$metrics_port_normal_2

docker run --name pfcpiface-normal-bess-3 -td --restart on-failure \
	--network host \
	-v /tmp:/tmp \
        -v "$PWD/conf/upf_normal_3.json":/conf/upf_normal_3.json \
        nfvri/upf-epc-pfcpiface:0.3.0-dev \
        -config /conf/upf_normal_3.json -bess localhost:$bessd_port_normal_3 -http 0.0.0.0:$metrics_port_normal_3

docker run --name pfcpiface-normal-bess-4 -td --restart on-failure \
	--network host \
	-v /tmp:/tmp \
        -v "$PWD/conf/upf_normal_4.json":/conf/upf_normal_4.json \
        nfvri/upf-epc-pfcpiface:0.3.0-dev \
        -config /conf/upf_normal_4.json -bess localhost:$bessd_port_normal_4 -http 0.0.0.0:$metrics_port_normal_4


# Don't run any other container if mode is "sim"
if [ "$mode" == 'sim' ]; then
        exit
fi

# Run routectl-bess
docker run --name routectl-premium-bess-1 -td --restart unless-stopped \
	--network host \
	-v "$PWD/conf/route_control_premium_1.py":/route_control_premium_1.py \
        --pid container:premium-bess-1 \
        --entrypoint /route_control_premium_1.py \
	nfvri/upf-epc-bess:0.3.0-dev -i "${ifaces[@]}"


docker run --name routectl-premium-bess-2 -td --restart unless-stopped \
	--network host \
        -v "$PWD/conf/route_control_premium_2.py":/route_control_premium_2.py \
        --pid container:premium-bess-2 \
        --entrypoint /route_control_premium_2.py \
        nfvri/upf-epc-bess:0.3.0-dev --port $bessd_port_premium_2 -i "${ifaces[@]}"

docker run --name routectl-premium-bess-3 -td --restart unless-stopped \
	--network host \
        -v "$PWD/conf/route_control_premium_3.py":/route_control_premium_3.py \
        --pid container:premium-bess-3 \
        --entrypoint /route_control_premium_3.py \
        nfvri/upf-epc-bess:0.3.0-dev --port $bessd_port_premium_3 -i "${ifaces[@]}"

docker run --name routectl-premium-bess-4 -td --restart unless-stopped \
	--network host \
        -v "$PWD/conf/route_control_premium_4.py":/route_control_premium_4.py \
        --pid container:premium-bess-4 \
        --entrypoint /route_control_premium_4.py \
        nfvri/upf-epc-bess:0.3.0-dev --port $bessd_port_premium_4 -i "${ifaces[@]}"

docker run --name routectl-normal-bess-1 -td --restart unless-stopped \
	--network host \
        -v "$PWD/conf/route_control_normal_1.py":/route_control_normal_1.py \
        --pid container:normal-bess-1 \
        --entrypoint /route_control_normal_1.py \
        nfvri/upf-epc-bess:0.3.0-dev --port $bessd_port_normal_1 -i "${ifaces[@]}"

docker run --name routectl-normal-bess-2 -td --restart unless-stopped \
	--network host \
        -v "$PWD/conf/route_control_normal_2.py":/route_control_normal_2.py \
        --pid container:normal-bess-2 \
        --entrypoint /route_control_normal_2.py \
        nfvri/upf-epc-bess:0.3.0-dev --port $bessd_port_normal_2 -i "${ifaces[@]}"

docker run --name routectl-normal-bess-3 -td --restart unless-stopped \
	--network host \
        -v "$PWD/conf/route_control_normal_3.py":/route_control_normal_3.py \
        --pid container:normal-bess-3 \
        --entrypoint /route_control_normal_3.py \
        nfvri/upf-epc-bess:0.3.0-dev --port $bessd_port_normal_3 -i "${ifaces[@]}"

docker run --name routectl-normal-bess-4 -td --restart unless-stopped \
	--network host \
        -v "$PWD/conf/route_control_normal_4.py":/route_control_normal_4.py \
        --pid container:normal-bess-4 \
        --entrypoint /route_control_normal_4.py \
        nfvri/upf-epc-bess:0.3.0-dev --port $bessd_port_normal_4 -i "${ifaces[@]}"

# Wait and add rules
sleep 90
docker exec pfcpiface-premium-bess-1 pfcpiface -config /conf/upf_premium_1.json -bess localhost:${bessd_port_premium_1} -simulate create &
sleep 5
docker exec pfcpiface-premium-bess-2 pfcpiface -config /conf/upf_premium_2.json -bess localhost:${bessd_port_premium_2} -simulate create &
sleep 5
docker exec pfcpiface-premium-bess-3 pfcpiface -config /conf/upf_premium_3.json -bess localhost:${bessd_port_premium_3} -simulate create &
sleep 5
docker exec pfcpiface-premium-bess-4 pfcpiface -config /conf/upf_premium_4.json -bess localhost:${bessd_port_premium_4} -simulate create &
sleep 5
docker exec pfcpiface-normal-bess-1 pfcpiface -config /conf/upf_normal_1.json -bess localhost:${bessd_port_normal_1} -simulate create &
sleep 5
docker exec pfcpiface-normal-bess-2 pfcpiface -config /conf/upf_normal_2.json -bess localhost:${bessd_port_normal_2} -simulate create &
sleep 5
docker exec pfcpiface-normal-bess-3 pfcpiface -config /conf/upf_normal_3.json -bess localhost:${bessd_port_normal_3} -simulate create &
sleep 5
docker exec pfcpiface-normal-bess-4 pfcpiface -config /conf/upf_normal_4.json -bess localhost:${bessd_port_normal_4} -simulate create &
sleep 5
