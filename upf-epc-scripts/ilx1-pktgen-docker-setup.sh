#!/bin/bash

#######
## Validated for clx1
#######

docker rm -f ilx1-pktgen-premium-access ilx1-pktgen-normal-access ilx1-pktgen-premium-core ilx1-pktgen-normal-core

## Start pktgen container
docker run --name ilx1-pktgen-premium-access -td --restart unless-stopped \
        --cpuset-cpus=21,23 --ulimit memlock=-1 --cap-add IPC_LOCK \
        -v /dev/hugepages:/dev/hugepages -v "$PWD/conf":/opt/bess/bessctl/conf  \
        --device=/dev/vfio/vfio --device=/dev/vfio/161 \
        ilx1-upf-epc-bess:0.3.0-dev -grpc-url=0.0.0.0:10514

docker run --name ilx1-pktgen-normal-access -td --restart unless-stopped \
        --cpuset-cpus=25,27 --ulimit memlock=-1 --cap-add IPC_LOCK \
        -v /dev/hugepages:/dev/hugepages -v "$PWD/conf":/opt/bess/bessctl/conf  \
        --device=/dev/vfio/vfio --device=/dev/vfio/162 \
        omecproject/upf-epc-bess:master-latest -grpc-url=0.0.0.0:10514

docker run --name ilx1-pktgen-premium-core -td --restart unless-stopped \
        --cpuset-cpus=29,31 --ulimit memlock=-1 --cap-add IPC_LOCK \
        -v /dev/hugepages:/dev/hugepages -v "$PWD/conf":/opt/bess/bessctl/conf  \
        --device=/dev/vfio/vfio --device=/dev/vfio/169 \
        ilx1-upf-epc-bess:0.3.0-dev -grpc-url=0.0.0.0:10514

docker run --name ilx1-pktgen-normal-core -td --restart unless-stopped \
        --cpuset-cpus=33,35 --ulimit memlock=-1 --cap-add IPC_LOCK \
        -v /dev/hugepages:/dev/hugepages -v "$PWD/conf":/opt/bess/bessctl/conf  \
        --device=/dev/vfio/vfio --device=/dev/vfio/170 \
        omecproject/upf-epc-bess:master-latest -grpc-url=0.0.0.0:10514

## Wait and start pktgen proper
sleep 80
docker exec ilx1-pktgen-premium-access ./bessctl run ilx1-pktgen-premium-access-weekly &
docker exec ilx1-pktgen-normal-access ./bessctl run ilx1-pktgen-normal-access-weekly &
docker exec ilx1-pktgen-premium-core ./bessctl run ilx1-pktgen-premium-core-weekly &
docker exec ilx1-pktgen-normal-core ./bessctl run ilx1-pktgen-normal-core-weekly &



## If things not working, try:
# sudo ip link set dev ens1f1 vf 2 trust on spoof off state enable promisc on
