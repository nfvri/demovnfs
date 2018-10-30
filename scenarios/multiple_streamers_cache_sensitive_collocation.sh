#!/bin/bash

num_streamers=6
first_streamer=1
num_cache_sens=3
first_cache_sens=1

let "last_streamer = first_streamer + num_streamers"
let "last_cache_sens = first_cache_sens + num_cache_sens"

for id in {$first_cache_sens..$last_cache_sens}; do
	let "port = 8800 + id"
	docker run --rm --detach -p $port:8001 --name cache-sensitive${id} nfvsap/cache-sensitive
done

for id in {$first_streamer..$last_streamer}; do
	let "port = 9800 + id"
	docker run --rm --detach -p $port:8002 --name streamer${id} nfvsap/streamer
done

 
