#!/bin/bash

#######
## Validated for clx1
#######

docker rm -f pktgen pktgen2 pktgen3 pktgen4

## Setup routes through pfcp
#docker exec bess-pfcpiface pfcpiface -config /conf/upf.json -simulate create

## Start pktgen container
docker run --name pktgen -td --restart unless-stopped \
        --cpuset-cpus=2,4 --ulimit memlock=-1 --cap-add IPC_LOCK \
        -v /dev/hugepages:/dev/hugepages -v "$PWD/conf":/opt/bess/bessctl/conf  \
        --device=/dev/vfio/vfio --device=/dev/vfio/145 \
        omecproject/upf-epc-bess:master-latest -grpc-url=0.0.0.0:10514

docker run --name pktgen2 -td --restart unless-stopped \
        --cpuset-cpus=6,8 --ulimit memlock=-1 --cap-add IPC_LOCK \
        -v /dev/hugepages:/dev/hugepages -v "$PWD/conf":/opt/bess/bessctl/conf  \
        --device=/dev/vfio/vfio --device=/dev/vfio/146 \
        omecproject/upf-epc-bess:master-latest -grpc-url=0.0.0.0:10514

docker run --name pktgen3 -td --restart unless-stopped \
        --cpuset-cpus=10,12 --ulimit memlock=-1 --cap-add IPC_LOCK \
        -v /dev/hugepages:/dev/hugepages -v "$PWD/conf":/opt/bess/bessctl/conf  \
        --device=/dev/vfio/vfio --device=/dev/vfio/153 \
        omecproject/upf-epc-bess:master-latest -grpc-url=0.0.0.0:10514

docker run --name pktgen4 -td --restart unless-stopped \
        --cpuset-cpus=14,16 --ulimit memlock=-1 --cap-add IPC_LOCK \
        -v /dev/hugepages:/dev/hugepages -v "$PWD/conf":/opt/bess/bessctl/conf  \
        --device=/dev/vfio/vfio --device=/dev/vfio/154 \
        omecproject/upf-epc-bess:master-latest -grpc-url=0.0.0.0:10514

## Wait and start pktgen proper
sleep 20
docker exec -it pktgen ./bessctl run pktgen
sleep 20
docker exec -it pktgen2 ./bessctl run pktgen2
sleep 20
docker exec -it pktgen3 ./bessctl run pktgen3
sleep 20
docker exec -it pktgen4 ./bessctl run pktgen4



## If things not working, try:
# sudo ip link set dev ens1f1 vf 2 trust on spoof off state enable promisc on
