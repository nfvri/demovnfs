## Run with Docker 

```
docker run --rm --detach -p 8800:8000 -p 8801:8001 -p 8802:8002 --name streamer1 nfvsap/streamer 
```

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

## How to remove cloud-init dependency
- ssh on the vm
- run: `cd /home/ubuntu/simple-em && sudo bash remove_cloud_init.sh`
After that you should be able to boot without .iso device.
