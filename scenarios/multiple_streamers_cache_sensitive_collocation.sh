#!/bin/bash

first_streamer_id=10
last_streamer_id=11
first_cache_sens_id=10
last_cache_sens_id=10

for (( id=$first_cache_sens_id; id<=$last_cache_sens_id; id++ )); do
	let "port = 8800 + id"
	docker run --rm --detach -p $port:8001 --name cache-sensitive${id} nfvsap/cache-sensitive
done

for (( id=$first_streamer_id; id<=$last_streamer_id; id++ )); do
	let "port = 9800 + id"
	docker run --rm --detach -p $port:8002 --name streamer${id} nfvsap/streamer
done

 
