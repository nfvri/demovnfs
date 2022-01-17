## Live streaming sample service

Requirements:
* `docker`
* `docker-compose`
* `ffmpeg`

Get a script usage:
```sh
./stress.sh -h
./upload/stream.sh -h
./download/stream.sh -h
```

Deploy the nginx rtmp service and exporters:
```sh
docker-compose up -d
```

Start the streamers:
```sh
./upload/stream.sh -u "rtmp:${ip}:1935/stream/"
	-f video.mp4 \
	-s 5
```

Build the hls download:
```sh
cd download
docker build -t hls .
```

Run the stream clients:
```sh
docker run --rm \
	--name=hls \
	hls \
	-d "http://${ip}:80/hls/" \
	-s 25 \
	-c 25
```

To stop the clients you will have to run `docker stop hls` from another terminal.
