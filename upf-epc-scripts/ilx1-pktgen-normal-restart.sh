#!/bin/bash

docker restart ilx1-pktgen-normal-access-1 ilx1-pktgen-normal-access-2 ilx1-pktgen-normal-core-1 ilx1-pktgen-normal-core-2

sleep 60
docker exec ilx1-pktgen-normal-access-1 ./bessctl run ilx1-pktgen-normal-access-static-1 &
docker exec ilx1-pktgen-normal-access-2 ./bessctl run ilx1-pktgen-normal-access-static-2 &
docker exec ilx1-pktgen-normal-core-1 ./bessctl run ilx1-pktgen-normal-core-static-1 &
docker exec ilx1-pktgen-normal-core-2 ./bessctl run ilx1-pktgen-normal-core-static-2 &
