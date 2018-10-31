# Run as Libvirt VM 

Provision with virgo: 

```console
$ sudo virgo provision cyclictest  -c virgo.json -p virgo_provision.sh -i virgo_initd.sh 
```

Start: 

```console
$ sudo virgo start cyclictest
```

# After launch

```console
$ curl http://<IP-addr>:9000/v1/data
```

