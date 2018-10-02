## Usage 

```
sudo bash make_vm.sh
```

## How to remove cloud-init dependency
- ssh on the vm
- run: `cd /home/ubuntu && sudo bash remove_cloud_init.sh`
After that you should be able to boot without .iso device.
