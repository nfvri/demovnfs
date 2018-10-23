#!/bin/bash

num_streamers=6
num_cache_sens=3

for id in `seq 1 1 $num_cache_sens`; do
	let "port = 8801 + id"
	docker run --rm --detach -p $port:8001 --name cache-sensitive${id} nfvsap/cache-sensitive
done

for id in `seq 1 1 $num_streamers`; do
	let "port = 8902 + id"
	docker run --rm --detach -p $port:8002 --name streamer${id} nfvsap/streamer
done

 
