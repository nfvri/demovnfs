This script creates a VM provisioned with: 
- Ubuntu 16.04
- DPDK built under /opt/nfv
- user-defined username and password 

Also, it launches a guest VM with the following capabilities: 
- configurable #vCPUs (all in a single socket)
- configurable memory size
- hugepages (assumes host support)
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
- `sudo bash create.sh provision`

To launch VM instance: 
- edit `vars.sh` as many times as needed
- `sudo bash create.sh lauch`
