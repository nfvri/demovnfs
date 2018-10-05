#!/usr/bin/env bash

source vars.sh
set -e
# requires the following packages on Ubuntu host:
#  apt-get install qemu-kvm libvirt-bin virtinst bridge-utils cloud-image-utils

let "LASTCPU=GUEST_VCPUS-1"

GUEST_NAME=$2

show_help() {
	scriptname=$(basename -- "$0")
	echo "Usage:"
	echo "1. Edit vars.sh according to the template"
	echo "2. Run 'sudo bash $scriptname provision <GUEST_NAME>' to provision the VM image"
	echo "3. Run 'sudo bash $scriptname launch <GUEST_NAME>' to launch the instance"
	echo "4. Run 'sudo bash $scriptname undefine <GUEST_NAME>' to undefine the instance"
	echo "5. Run 'sudo bash $scriptname unprovision <GUEST_NAME>' to undefine the instance and remove its volumes"
}

create_cloud_config() {
	# cloud-init config files : specify cloud-init data for your guest
	cat <<EOF > meta-data
instance-id: iid-${GUEST_NAME};
#hostname: ${GUEST_NAME}
#local-hostname: ${GUEST_NAME}
EOF

	cat <<EOF > user-data
#cloud-config
users:
  - name: ${USER_NAME}
    lock_passwd: false
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    passwd: $(openssl passwd -1 -salt SaltSalt ${USER_PASSWD})

write_files:
  - path: /provision.sh
    content: |
      #!/usr/bin/env bash
      mkdir -p /opt/nfv 
      cd /opt/nfv
      wget http://fast.dpdk.org/rel/dpdk-16.07.tar.xz
      tar -xvf dpdk-16.07.tar.xz
      export RTE_SDK=\$(pwd)/dpdk-16.07
      export RTE_TARGET=x86_64-native-linuxapp-gcc
      cd \$RTE_SDK
      make config T=\$RTE_TARGET
      make install T=\$RTE_TARGET DESTDIR=dpdk-install
      mkdir -p /opt/nfv/trex
      cd /opt/nfv/trex
      wget --no-cache http://trex-tgn.cisco.com/trex/release/v2.45.tar.gz

  - path: /remove_cloud_init.sh
    content: |
      #!/usr/bin/env bash
      echo 'datasource_list: [ None ]' | sudo -s tee /etc/cloud/cloud.cfg.d/90_dpkg.cfg
      sudo apt-get purge -y cloud-init
      sudo rm -rf /etc/cloud/; sudo rm -rf /var/lib/cloud/


password: $USER_PASSWD
chpasswd: { expire: False }
ssh_pwauth: True

# upgrade packages on startup
package_upgrade: true

#run 'apt-get upgrade' or yum equivalent on first boot
apt_upgrade: true

packages: 
  - gcc
  - make
  - libvirt-bin
  - python

runcmd:
  - bash /provision.sh
  - bash /remove_cloud_init.sh
  - uname -a
  - shutdown

power_state:
  mode: reboot
EOF
}

create_dom_xml() {
	cat <<EOF > dom.xml
<domain type='kvm'>
  <name>$GUEST_NAME</name>
  <!-- uuid>4a9b3f53-fa2a-47f3-a757-dd87720d9d1d</uuid -->
  <memory unit='MiB'>$GUEST_MEM_MB</memory>
  <currentMemory unit='MiB'>$GUEST_MEM_MB</currentMemory>
EOF

	if (( $GUEST_HUGEPAGES == 1 )); then
		cat <<EOF >> dom.xml
  <memoryBacking>
    <hugepages/>
    <!-- hugepages>
      <page size='2' unit='M' nodeset='0'/>
    </hugepages -->
  </memoryBacking>
EOF
	fi

	cat << EOF >> dom.xml
  <vcpu placement='static'>$GUEST_VCPUS</vcpu>
  <!-- cputune>
    <shares>4096</shares>
    <vcpupin vcpu='0' cpuset='4'/>
    <vcpupin vcpu='1' cpuset='5'/>
    <emulatorpin cpuset='4,5'/>
  </cputune -->
  <os>
    <type arch='x86_64' machine='pc'>hvm</type>
    <boot dev='hd'/>
  </os>
  <features>
    <acpi/>
    <apic/>
  </features>
  <cpu mode='host-model'>
    <model fallback='allow'/>
    <topology sockets='1' cores='$GUEST_VCPUS' threads='1'/>
    <numa>
EOF
	if (( $GUEST_HUGEPAGES == 1 )); then
		echo "<cell id='0' cpus='0-$LASTCPU' memory='$GUEST_MEM_MB' unit='MiB' memAccess='shared'/>" >> dom.xml
	else		
		echo "<cell id='0' cpus='0-$LASTCPU' memory='$GUEST_MEM_MB' unit='MiB'/>" >> dom.xml
	fi
	
	cat << EOF >> dom.xml
    </numa>
  </cpu>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>destroy</on_crash>
  <devices>
    <emulator>/usr/bin/qemu-system-x86_64</emulator>
    <!-- emulator>/usr/bin/kvm-spice</emulator -->
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2'/>
      <source file='${POOL_PATH}/${GUEST_NAME}.root.img'/>
      <target dev='vda' bus='virtio'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x07' function='0x0'/>
    </disk>
    <disk type='file' device='disk'>
      <driver name='qemu' type='raw'/>
      <source file='${POOL_PATH}/${GUEST_NAME}.configuration.iso'/>
      <target dev='vdb' bus='virtio'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x08' function='0x0'/>
    </disk>
EOF

	for NIF in `seq 1 10`
	do
		t="GUEST_NETIF${NIF}_TYPE"
	  	if [[ -v t ]]
  		then
			if [ "${!t}" = "bridge" ]
			then
				b="GUEST_NETIF${NIF}_BRIDGE"
				echo "    <interface type='${!t}'>" >> dom.xml
				echo "      <source bridge='${!b}' />" >> dom.xml
				echo "      <model type='virtio'/>" >> dom.xml
				echo "    </interface>" >> dom.xml

			elif [ "${!t}" = "vhostuser" ]
			then
				m="GUEST_NETIF${NIF}_MACADDR"
				u="GUEST_NETIF${NIF}_UNIXPATH"
				q="GUEST_NETIF${NIF}_QUEUES"
				echo "    <interface type='${!t}'>" >> dom.xml
				echo "      <mac address='${!m}'/>" >> dom.xml
      			        echo "      <source type='unix' path='${!u}' mode='client'/>" >> dom.xml
      		        	echo "      <model type='virtio'/>" >> dom.xml
	      		        echo "      <driver queues='${!q}'>" >> dom.xml
        		        echo "        <host mrg_rxbuf='on'/>" >> dom.xml
      			        echo "      </driver>" >> dom.xml
				echo "    </interface>" >> dom.xml
		        fi
	  	fi
	done

	cat <<EOF >> dom.xml    
    <serial type='pty'>
      <target port='0'/>
    </serial>
    <console type='pty'>
      <target type='serial' port='0'/>
    </console>
  </devices>
</domain>
EOF
}

download_image() {
	if [[ ! -f ${CLOUD_IMG_PATH}/${CLOUD_IMG_NAME} ]]; then
		echo "Downloading image ${CLOUD_IMG_NAME}..."
      		wget ${CLOUD_IMG_URL}/${CLOUD_IMG_NAME} -O ${CLOUD_IMG_PATH}/${CLOUD_IMG_NAME}
	fi
}

create_volumes() {
	# check if pool exists, otherwise create it
	if [[ "$(virsh pool-list|grep ${POOL} -c)" -ne "1" ]]; then
		virsh pool-define-as --name ${POOL} --type dir --target ${POOL_PATH}
	      	virsh pool-autostart ${POOL}
	      	virsh pool-build ${POOL}
	      	virsh pool-start ${POOL}
	fi

	# write the two cloud-init files into an ISO
	genisoimage -output configuration.iso -volid cidata -joliet -rock user-data meta-data
	#cloud-localds configuration.iso user-data meta-data

	# copy ISO into libvirt's directory
	cp configuration.iso ${POOL_PATH}/${GUEST_NAME}.configuration.iso
	virsh pool-refresh ${POOL}

	# copy image to libvirt's pool
	if [[ ! -f ${POOL_PATH}/${CLOUD_IMG_NAME} ]]; then
	      cp ${CLOUD_IMG_PATH}/${CLOUD_IMG_NAME} ${POOL_PATH}
      	      virsh pool-refresh ${POOL}
      	fi

	# clone cloud image
	virsh vol-clone --pool ${POOL} ${CLOUD_IMG_NAME} ${GUEST_NAME}.root.img
	# virsh vol-resize --pool ${POOL} ${GUEST_NAME}.root.img ${GUEST_VROOTDISKSIZE}

	# convert image format
	if [[ "${CONVERT}" == "yes" ]]; then
		echo "Converting image to format ${FORMAT}..."
	      	qemu-img convert -O ${FORMAT} ${POOL_PATH}/${GUEST_NAME}.root.img ${POOL_PATH}/${GUEST_NAME}.root.img.${FORMAT}
	      	rm ${POOL_PATH}/${GUEST_NAME}.root.img
	      	mv ${POOL_PATH}/${GUEST_NAME}.root.img.${FORMAT} ${POOL_PATH}/${GUEST_NAME}.root.img
	fi
}

create_guest() {
	virsh undefine ${GUEST_NAME} || true
	virsh define dom.xml
	virsh start ${GUEST_NAME}
}

display_result() {
	virsh list
}

cleanup() {
	rm configuration.iso user-data meta-data
}

if [ -z "$2" ]; then
	show_help
	exit
fi

if [ "$1" == "provision" ]; then
	create_cloud_config
	download_image
	create_volumes
	create_dom_xml
	create_guest
	display_result
	cleanup
elif [ "$1" == "launch" ]; then
	create_dom_xml
	create_guest
elif [ "$1" == "undefine" ]; then
	virsh undefine ${GUEST_NAME}
elif [ "$1" == "unprovision" ]; then
	virsh undefine ${GUEST_NAME} || true
	rm ${POOL_PATH}/${GUEST_NAME}.root.img
	rm ${POOL_PATH}/${GUEST_NAME}.configuration.iso
else
	show_help
fi
