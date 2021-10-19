#!/bin/bash

#######
## Validated for clx1
#######

docker rm -f pktgen-premium-access pktgen-normal-access pktgen-premium-core pktgen-normal-core

## Start pktgen container
docker run --name pktgen-premium-access -td --restart unless-stopped \
        --cpuset-cpus=2,4 --ulimit memlock=-1 --cap-add IPC_LOCK \
        -v /dev/hugepages:/dev/hugepages -v "$PWD/conf":/opt/bess/bessctl/conf  \
        --device=/dev/vfio/vfio --device=/dev/vfio/145 \
        omecproject/upf-epc-bess:master-latest -grpc-url=0.0.0.0:10514

docker run --name pktgen-normal-access -td --restart unless-stopped \
        --cpuset-cpus=6,8 --ulimit memlock=-1 --cap-add IPC_LOCK \
        -v /dev/hugepages:/dev/hugepages -v "$PWD/conf":/opt/bess/bessctl/conf  \
        --device=/dev/vfio/vfio --device=/dev/vfio/146 \
        omecproject/upf-epc-bess:master-latest -grpc-url=0.0.0.0:10514

docker run --name pktgen-premium-core -td --restart unless-stopped \
        --cpuset-cpus=10,12 --ulimit memlock=-1 --cap-add IPC_LOCK \
        -v /dev/hugepages:/dev/hugepages -v "$PWD/conf":/opt/bess/bessctl/conf  \
        --device=/dev/vfio/vfio --device=/dev/vfio/153 \
        omecproject/upf-epc-bess:master-latest -grpc-url=0.0.0.0:10514

docker run --name pktgen-normal-core -td --restart unless-stopped \
        --cpuset-cpus=14,16 --ulimit memlock=-1 --cap-add IPC_LOCK \
        -v /dev/hugepages:/dev/hugepages -v "$PWD/conf":/opt/bess/bessctl/conf  \
        --device=/dev/vfio/vfio --device=/dev/vfio/154 \
        omecproject/upf-epc-bess:master-latest -grpc-url=0.0.0.0:10514

## Wait and start pktgen proper
sleep 80
docker exec pktgen-premium-access ./bessctl run pktgen-premium-access &
docker exec pktgen-normal-access ./bessctl run pktgen-normal-access &
docker exec pktgen-premium-core ./bessctl run pktgen-premium-core &
docker exec pktgen-normal-core ./bessctl run pktgen-normal-core &



## If things not working, try:
# sudo ip link set dev ens1f1 vf 2 trust on spoof off state enable promisc on
