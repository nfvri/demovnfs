#!/usr/bin/env bash

set -ex

#
# requires the following packages on Ubuntu host:
#  apt-get install qemu-kvm libvirt-bin virtinst bridge-utils cloud-image-utils

USER_NAME="ubuntu"
USER_PASSWD="ubuntu"
IMG="xenial"
ARCH="amd64"
IMG_URL="https://cloud-images.ubuntu.com/releases/16.04/release"
IMG_NAME="ubuntu-16.04-server-cloudimg-${ARCH}-disk1.img"
IMG_PATH=.
KVM_DEF_POOL=default
KVM_DEF_POOL_PATH=/var/lib/libvirt/images

# vm prefs : specify vm preferences for your guest
GUEST_NAME="dpdk-vm"
GUEST_DOMAIN=intranet.local
#GUEST_VROOTDISKSIZE=10G
GUEST_VCPUS=4
GUEST_VMEM=4096
GUEST_NETWORK="bridge=virbr0,model=virtio"


# guest image format: qcow2 or raw
FORMAT=qcow2
# convert image format : yes or no
CONVERT=no

# kvm pool
POOL=$KVM_DEF_POOL
POOL_PATH=$KVM_DEF_POOL_PATH
#POOL=nanastop
#POOL_PATH=/store/images/demovnfs

#
# cloud-init config files : specify cloud-init data for your guest
cat <<EOF > meta-data
instance-id: iid-${GUEST_NAME};
#hostname: ${GUEST_NAME}
#local-hostname: ${GUEST_NAME}
EOF

cat <<EOF > user-data
#cloud-config
users:
  - name: nfvsap
    lock_passwd: false
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    passwd: $(openssl passwd -1 -salt SaltSalt nfvsap)
write_files:
  - path: /provision.sh
    content: |
      #!/usr/bin/env bash
      mkdir -p /opt/nfv 
      cd /opt/nfv
      wget http://fast.dpdk.org/rel/dpdk-16.07.tar.xz
      tar -xvf dpdk-16.07.tar.xz
      export RTE_SDK=$(pwd)/dpdk-16.07
      export RTE_TARGET=x86_64-native-linuxapp-gcc
      cd $RTE_SDK
      make config T=x86_64-native-linuxapp-gcc
      make install T=x86_64-native-linuxapp-gcc DESTDIR=dpdk-install

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

runcmd:
  - bash /provision.sh
  - bash /remove_cloud_init.sh
  - shutdown

power_state:
  mode: reboot
EOF

# don't edit below unless you know wat you're doing!

# check if the script is run as root user
if [[ $USER != "root" ]]; then
  echo "This script must be run as root!" && exit 1
fi


if [[ ! -f ${IMG_PATH}/${IMG_NAME} ]]; then
  echo "Downloading image ${IMG_NAME}..."
  wget ${IMG_URL}/${IMG_NAME} -O ${IMG_PATH}/${IMG_NAME}
fi

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

# keep a backup of the files for future reference
cp user-data user-data.${GUEST_NAME}
cp meta-data meta-data.${GUEST_NAME}

# copy ISO into libvirt's directory
cp configuration.iso ${POOL_PATH}/${GUEST_NAME}.configuration.iso
virsh pool-refresh ${POOL}

# copy image to libvirt's pool
if [[ ! -f ${POOL_PATH}/${IMG_NAME} ]]; then
  cp ${IMG_PATH}/${IMG_NAME} ${POOL_PATH}
  virsh pool-refresh ${POOL}
fi

# clone cloud image
virsh vol-clone --pool ${POOL} ${IMG_NAME} ${GUEST_NAME}.root.img
# virsh vol-resize --pool ${POOL} ${GUEST_NAME}.root.img ${GUEST_VROOTDISKSIZE}

# convert image format
if [[ "${CONVERT}" == "yes" ]]; then
  echo "Converting image to format ${FORMAT}..."
  qemu-img convert -O ${FORMAT} ${POOL_PATH}/${GUEST_NAME}.root.img ${POOL_PATH}/${GUEST_NAME}.root.img.${FORMAT}
  rm ${POOL_PATH}/${GUEST_NAME}.root.img
  mv ${POOL_PATH}/${GUEST_NAME}.root.img.${FORMAT} ${POOL_PATH}/${GUEST_NAME}.root.img
fi

echo "Creating guest ${GUEST_NAME}..."
virt-install \
  --name ${GUEST_NAME} \
  --ram ${GUEST_VMEM} \
  --vcpus=${GUEST_VCPUS},sockets=1,cores=${GUEST_VCPUS},threads=1 \
  --autostart \
  --memballoon virtio \
  --network ${GUEST_NETWORK} \
  --boot hd \
  --disk vol=${POOL}/${GUEST_NAME}.root.img,format=${FORMAT},bus=virtio \
  --disk vol=${POOL}/${GUEST_NAME}.configuration.iso,bus=virtio \
  --noautoconsole

# display result
echo
echo "List of running VMs :"
echo
virsh list

# cleanup
rm configuration.iso user-data* meta-data* 

echo
echo "************************"
echo "Useful stuff to remember"
echo "************************"
echo
echo "To login to vm guest:"
echo " sudo virsh console ${GUEST_NAME}"
echo "Default user for cloud image is :"
echo " ${USER_NAME}"
echo
echo "To edit guest vm config:"
echo " sudo virsh edit ${GUEST_NAME}"
echo
echo "To create a volume:"
echo " virsh vol-create-as ${POOL} ${GUEST_NAME}.vol1.img 20G --format ${FORMAT}"
echo "To attach a volume to an existing guest:"
echo " virsh attach-disk ${GUEST_NAME} --source ${POOL_PATH}/${GUEST_NAME}.vol1.img --target vdc --driver qemu --subdriver ${FORMAT} --persistent"
echo "To prepare the newly attached volume on guest:"
echo " sgdisk -n 1 -g /dev/vdc && && mkfs -t ext4 /dev/vdc1 && sgdisk -c 1:'vol1' -g /dev/vdc && sgdisk -p /dev/vdc"
echo " mkdir /mnt/vol1"
echo " echo '/dev/vdc1 /mnt/vol1 ext4 defaults,relatime 0 0' >> /etc/fstab"
echo
echo "To shutdown a guest vm:"
echo "  sudo virsh shutdown ${GUEST_NAME}"
echo
