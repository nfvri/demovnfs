#!/bin/bash

docker restart ilx1-pktgen-premium-access-1 ilx1-pktgen-premium-access-2 ilx1-pktgen-premium-core-1 ilx1-pktgen-premium-core-2

sleep 60
docker exec ilx1-pktgen-premium-access-1 ./bessctl run ilx1-pktgen-premium-access-static-1 &
docker exec ilx1-pktgen-premium-access-2 ./bessctl run ilx1-pktgen-premium-access-static-2 &
docker exec ilx1-pktgen-premium-core-1 ./bessctl run ilx1-pktgen-premium-core-static-1 &
docker exec ilx1-pktgen-premium-core-2 ./bessctl run ilx1-pktgen-premium-core-static-2 &