# Features
- Ubuntu 16.04
- Multile DPDK versions built under /opt/nfv
- TRex built under /opt/nfv
- scapy

__NOTE__: we must rebuild DPDK after provisioning, because the `igb_uio`
module cannot be loaded due to kernel incompatibilities: it was built against
a kernel version, which gets updated during the VM provisioning (the VM boots 
after the provisioning with the newer kernel).

# Usage 

To provision the VM image:

```console
$ sudo virgo provision dpdk-vm -c virgo.json -p virgo_provision.sh
```

To launch the VM, edit `virgo.json` to specify the desired configuration and 
issue: 

```console
$ sudo virgo launch dpdk-vm -c virgo.json
```
