# Run as Libvirt VM 

Provision with virgo: 

```console
$ sudo virgo provision  -c virgo.json -p virgo_provision.sh -i virgo_initd.sh -g cyclictest
```

Start: 

```console
$ sudo virgo start -g cyclictest
```

# After launch

```console
$ curl http://<IP-addr>:9000/v1/data
```

