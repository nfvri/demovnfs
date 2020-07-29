# Run as Libvirt VM 

Provision with virgo: 

```console
$ sudo virgo provision cache-sensitive-vnf  -c virgo.json -p virgo_provision.sh -i virgo_initd.sh 
```

Start: 

```console
$ sudo virgo start cache-sensitive-vnf
```

# Run as Docker container

You can start the "cache-sensitive" benchmark as a Docker container, providing the desired working set size (WSS) in the command line as follows: 

``` 
docker run --rm --detach -p 8800:8000 -p 8801:8001 -p 8802:8002 --name cache-sensitive1 nfvsap/cache-sensitive /bin/bash /run.sh 15
```

In this example, we use a WSS of 15 MB.


# After launch

```console
$ curl http://<IP-addr>:8800/v1/data
```

or use the 8801, 8802 ports.
