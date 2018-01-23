## Usage 

```
sudo bash make_vm.sh
```

After provisioning: 

```
curl http://<IP-addr>:8000/v1/data
```

or

```
curl http://<IP-addr>:8002/v1/data
```

## Changes compared to baseline

- use `virbr1` instead of `virbr0`
- do not resize volume to 10G


### How to remove cloud-init dependency
- ssh on the vm
- run: `cd /home/ubuntu/go-work/src/hist-em && sudo bash remove_cloud_init.sh`
After that you should be able to boot without .iso device.
