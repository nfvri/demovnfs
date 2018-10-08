This script creates a VM provisioned with: 
- Ubuntu 16.04
- DPDK built under /opt/nfv
- user-defined username and password 

__NOTE__: it seems that we must rebuild DPDK after provisioning, because the igb_uio 
module cannot be loaded due to kernel incompatibilities. It seems that it has been built 
with the initial version of the kernel, before the upgrade.

Also, it launches a guest VM with the following capabilities: 
- configurable #vCPUs (all in a single socket)
- configurable memory size
- optional hugepage-based backing memory (assumes host support)
- vhostuser-type network interfaces to use with OVS-DPDK
- bridge-type network interfaces for management 

The script searches for vars `GUEST_NETIF{X}_TYPE` to create the 
corresponding network interfaces, where X=1..10. 

The following parameters can be specified for vhostuser-type networks interfaces: 
- MAC address
- Unix path
- number of queues

and for bridge-type interfaces: 
- host bridge (e.g. `virbr0`)

## Usage 

To provision VM image: 
- edit `vars.sh`
- `sudo ./vm.sh provision <GUEST_NAME>`

To launch VM instance: 
- edit `vars.sh` as many times as needed
- `sudo ./vm.sh launch <GUEST_NAME>`

To destroy (undefine) the instance without destroying its disk: 
- `sudo ./vm.sh undefine <GUEST_NAME>`

To destroy (undefine) the instance AND its disk: 
- `sudo ./vm.sh unprovision <GUEST_NAME>`



