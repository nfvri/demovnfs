#!/bin/bash

#######
## Validated for clx1
#######

docker rm -f ilx1-pktgen-premium-access ilx1-pktgen-normal-access ilx1-pktgen-premium-core ilx1-pktgen-normal-core ilx1-pktgen-premium-access-1 ilx1-pktgen-premium-access-2 ilx1-pktgen-normal-access-1 ilx1-pktgen-normal-access-2 ilx1-pktgen-premium-core-1 ilx1-pktgen-premium-core-2 ilx1-pktgen-normal-core-1 ilx1-pktgen-normal-core-2

## Start pktgen container
docker run --name ilx1-pktgen-premium-access-1 -td --restart unless-stopped \
        --cpuset-cpus=1,33,5,37 --ulimit memlock=-1 --cap-add IPC_LOCK \
        -v /dev/hugepages:/dev/hugepages -v "$PWD/conf":/opt/bess/bessctl/conf:ro  \
        --device=/dev/vfio/vfio --device=/dev/vfio/161 \
        ilx1-upf-epc-bess:0.3.0-dev -grpc-url=0.0.0.0:10514

docker run --name ilx1-pktgen-premium-access-2 -td --restart unless-stopped \
        --cpuset-cpus=9,41,13,45 --ulimit memlock=-1 --cap-add IPC_LOCK \
        -v /dev/hugepages:/dev/hugepages -v "$PWD/conf":/opt/bess/bessctl/conf:ro  \
        --device=/dev/vfio/vfio --device=/dev/vfio/163 \
        ilx1-upf-epc-bess:0.3.0-dev -grpc-url=0.0.0.0:10514

docker run --name ilx1-pktgen-normal-access-1 -td --restart unless-stopped \
        --cpuset-cpus=15,47,11,43 --ulimit memlock=-1 --cap-add IPC_LOCK \
        -v /dev/hugepages:/dev/hugepages -v "$PWD/conf":/opt/bess/bessctl/conf:ro  \
        --device=/dev/vfio/vfio --device=/dev/vfio/162 \
        omecproject/upf-epc-bess:master-latest -grpc-url=0.0.0.0:10514

docker run --name ilx1-pktgen-normal-access-2 -td --restart unless-stopped \
        --cpuset-cpus=7,39,3,35 --ulimit memlock=-1 --cap-add IPC_LOCK \
        -v /dev/hugepages:/dev/hugepages -v "$PWD/conf":/opt/bess/bessctl/conf:ro  \
        --device=/dev/vfio/vfio --device=/dev/vfio/164 \
        omecproject/upf-epc-bess:master-latest -grpc-url=0.0.0.0:10514

docker run --name ilx1-pktgen-premium-core-1 -td --restart unless-stopped \
        --cpuset-cpus=17,49,21,53 --ulimit memlock=-1 --cap-add IPC_LOCK \
        -v /dev/hugepages:/dev/hugepages -v "$PWD/conf":/opt/bess/bessctl/conf:ro  \
        --device=/dev/vfio/vfio --device=/dev/vfio/169 \
        ilx1-upf-epc-bess:0.3.0-dev -grpc-url=0.0.0.0:10514

docker run --name ilx1-pktgen-premium-core-2 -td --restart unless-stopped \
        --cpuset-cpus=25,57,29,61 --ulimit memlock=-1 --cap-add IPC_LOCK \
        -v /dev/hugepages:/dev/hugepages -v "$PWD/conf":/opt/bess/bessctl/conf:ro  \
        --device=/dev/vfio/vfio --device=/dev/vfio/171 \
        ilx1-upf-epc-bess:0.3.0-dev -grpc-url=0.0.0.0:10514

docker run --name ilx1-pktgen-normal-core-1 -td --restart unless-stopped \
        --cpuset-cpus=31,63,27,59 --ulimit memlock=-1 --cap-add IPC_LOCK \
        -v /dev/hugepages:/dev/hugepages -v "$PWD/conf":/opt/bess/bessctl/conf:ro  \
        --device=/dev/vfio/vfio --device=/dev/vfio/170 \
        omecproject/upf-epc-bess:master-latest -grpc-url=0.0.0.0:10514

docker run --name ilx1-pktgen-normal-core-2 -td --restart unless-stopped \
        --cpuset-cpus=23,55,19,51 --ulimit memlock=-1 --cap-add IPC_LOCK \
        -v /dev/hugepages:/dev/hugepages -v "$PWD/conf":/opt/bess/bessctl/conf:ro  \
        --device=/dev/vfio/vfio --device=/dev/vfio/172 \
        omecproject/upf-epc-bess:master-latest -grpc-url=0.0.0.0:10514

## Wait and start pktgen proper
sleep 180
# docker exec ilx1-pktgen-premium-access-1 ./bessctl run ilx1-pktgen-premium-access-static-1 &
# docker exec ilx1-pktgen-premium-access-2 ./bessctl run ilx1-pktgen-premium-access-static-2 &
# docker exec ilx1-pktgen-normal-access-1 ./bessctl run ilx1-pktgen-normal-access-static-1 &
# docker exec ilx1-pktgen-normal-access-2 ./bessctl run ilx1-pktgen-normal-access-static-2 &
# docker exec ilx1-pktgen-premium-core-1 ./bessctl run ilx1-pktgen-premium-core-static-1 &
# docker exec ilx1-pktgen-premium-core-2 ./bessctl run ilx1-pktgen-premium-core-static-2 &
# docker exec ilx1-pktgen-normal-core-1 ./bessctl run ilx1-pktgen-normal-core-static-1 &
# docker exec ilx1-pktgen-normal-core-2 ./bessctl run ilx1-pktgen-normal-core-static-2 &
docker exec ilx1-pktgen-premium-access-1 ./bessctl run ilx1-pktgen-premium-access-weekly-1 &
docker exec ilx1-pktgen-premium-access-2 ./bessctl run ilx1-pktgen-premium-access-weekly-2 &
docker exec ilx1-pktgen-normal-access-1 ./bessctl run ilx1-pktgen-normal-access-weekly-1 &
docker exec ilx1-pktgen-normal-access-2 ./bessctl run ilx1-pktgen-normal-access-weekly-2 &
docker exec ilx1-pktgen-premium-core-1 ./bessctl run ilx1-pktgen-premium-core-weekly-1 &
docker exec ilx1-pktgen-premium-core-2 ./bessctl run ilx1-pktgen-premium-core-weekly-2 &
docker exec ilx1-pktgen-normal-core-1 ./bessctl run ilx1-pktgen-normal-core-weekly-1 &
docker exec ilx1-pktgen-normal-core-2 ./bessctl run ilx1-pktgen-normal-core-weekly-2 &



## If things not working, try:
# sudo ip link set dev ens1f1 vf 2 trust on spoof off state enable promisc on
