#!/bin/bash

PATTERN_FILE=${1:-"../../patterns/small-pattern.txt"}
readarray -t CLIENTS_ARR < $PATTERN_FILE

while true ;
do
redis-cli FLUSHDB ;
redis-benchmark -t set -d 1000000 -n 10000 -c 100 -r 10000 -q ;
    for CLIENTS in "${CLIENTS_ARR[@]}"
    do
        CLIENTS=${CLIENTS//$'\n'/ }
        CLIENTS=${CLIENTS//$'\r'/ }
        echo "CLIENTS: $CLIENTS"
        redis-benchmark -t get -d 1000000 -n 1000000 -c $CLIENTS -r 10000
    done
done