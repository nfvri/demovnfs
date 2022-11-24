#!/bin/bash

let i=10;
let down=0;

redis-cli FLUSHDB ; 
redis-benchmark -t set -d 1000000 -n 10000 -c 100 -r 10000 -q ;

while true ;
do
    if [ $i -gt 1000 ] ; 
    then
        let down=1 ;
    fi
    if [ $i -le 10 ] ;
    then
        let down=0 ;
    fi
    # let load=10000*$i
    echo "$i"
    # redis-cli FLUSHDB ; 
    for j in $(seq 0 9); 
    do
	redis-benchmark -t get -d 1000000 -n 10000 -c $i -r 10000
    done
    if [ $down -gt 0 ];
    then
	let i=$i-10 ;
    else
	let i=$i+10 ;
    fi
done
