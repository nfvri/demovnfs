# Run as Libvirt VM 

Provision with virgo: 

```console
$ sudo virgo provision streamer1  -c virgo.json -p virgo_provision.sh -i virgo_initd.sh 
```


Start: 

```console
$ sudo virgo start streamer-vnf
```

# Run as Docker container

```
docker run --rm --detach -p 8800:8000 -p 8801:8001 -p 8802:8002 --name streamer1 nfvri/streamer:20.04
```

```
docker run --rm --detach -p 8800:8000 -p 8801:8001 -p 8802:8002 --name streamer1 nfvri/streamer:20.04 "archbench/memory_tests/seqacc" "150" "2>&1" ">/dev/null" "|" "/go/bin/simple-em"
```

# After launch

```console
$ curl http://<IP-addr>:8000/v1/data
```

or use the 8001, 8002 ports.
