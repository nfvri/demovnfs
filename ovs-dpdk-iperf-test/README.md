# OVS/DPDK iperf test

## OVS/DPDK installation

To install the OVS with DPDK support for Ubuntu you should follow
[these](https://ubuntu.com/server/docs/openvswitch-dpdk) instructions. On other distributions you
should install the distribution's package. Otherwise if not available, or you want to install a
newer version, you can follow [these](https://docs.openvswitch.org/en/latest/intro/install/dpdk/)
instructions.

## Ubuntu VM

To use the libvirt `ubuntu-vm.xml` you must have a Ubuntu cloud image. The xml provided expects one
at `/var/lib/libvirt/images/ubuntu1.img`. You should use a new copy of the image for each instance.
You can create the VM with `virsh`:

```sh
# virsh create --file ./ubuntu-vm.xml
```

## Static IP assignment

To be able to connect to the VMs via SSH and to perform the tests you need to configure the
networking. Here we will show how to assign static IPs.

Connect to the VM via:

```sh
# virsh console ubuntu1
```

Edit the `/etc/netplan/99_config.yaml`:

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp1s0:
      match:
        macaddress: 52:54:00:ec:70:dd
      addresses:
        - 172.2.2.101/24
```

To access the VM from the host assign an IP to the bridge:

```sh
# ip link set ovsdpdkbr0 up
# ip addr add 172.2.2.1/24 dev ovsdpdkbr0
```

Apply the configuration:

```sh
# netplan apply
```

## Starting the iperf servers & clients

The scripts assume the servers are named like `ubuntu{id}` and are either in the `/etc/hosts`
either named the `~/.ssh/config` i.e.:

```
Host ubuntu1
  Hostname 172.2.2.101
  IdentityFile ~/.ssh/id_rsa
  User ubuntu
```

The user running must have be able to ssh without a password, for example using an rsa key like
above.

You can run all the servers with:

```sh
$ ./iperf-servers-up.sh
```

And kill them with:

```sh
$ ./iperf-killall-servers.sh
```

You can run all the client with:

```sh
$ ./iperf-clients-up.sh {threads} {bitrate}
```

And kill them with:

```sh
$ ./iperf-killall-clients.sh
```

