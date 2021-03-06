## From https://gist.github.com/krsna1729/9646f76a9928764d66405a3d4e783dc6
FROM ubuntu:focal as ubuntu-build
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confold" -y install \
        build-essential \
        git \
        libnuma-dev \
        libpcap-dev \
        iproute2 \
        python3 \
        python3-pip \
        pciutils \
        pkg-config \
        curl \
        wget \
        meson \
        ninja-build \
     && apt clean

ARG DPDK_VER='master'
ENV DPDK_DIR='/dpdk'
ENV RTE_TARGET='x86_64-native-linuxapp-gcc'
ENV RTE_SDK=${DPDK_DIR}
RUN git clone -b $DPDK_VER -q --depth 1 https://github.com/DPDK/dpdk.git $DPDK_DIR 2>&1
RUN cd ${DPDK_DIR} && \
    meson -Dexamples=l2fwd,l3fwd,l3fwd-acl build && \
    cd build && \
    ninja && \
    ninja install &&\
    ldconfig

# Add examples to path
ENV PATH="$PATH:$DPDK_DIR/build/examples/"

# Install DPDK pktgen
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get -o Dpkg::Options::="--force-confold" -y install \
        lua5.3 \
        liblua5.3-dev \
        vim \
     && apt clean

ENV PKTGEN_DIR='/pktgen-dpdk'
RUN git clone -q --depth 1 https://github.com/pktgen/Pktgen-DPDK.git $PKTGEN_DIR 2>&1
RUN cd ${PKTGEN_DIR} && \
    make buildlua

########## OLD BUILD PATH WITH MAKE ##########

#    make config T=x86_64-native-linuxapp-gcc MAKE_PAUSE=n && \
#    make MAKE_PAUSE=n -j $CPUS

# Add app to path
#ENV PATH="$PATH:$DPDK_DIR/build/app/"

## Build examples for testing
#RUN cd ${DPDK_DIR}/examples/l2fwd && \
#    unset RTE_TARGET &&  make

## Set default DPDK library path
#ENV LD_LIBRARY_PATH=${DPDK_DIR}/build/lib/

########## OLD BUILD PATH WITH MAKE ##########

########## OLD BUILD PATH WITH TREX ##########

# install T-Rex
#ARG TREX_VER='v2.83'
#RUN mkdir -p /opt/nfv/trex && \ 
#    cd /opt/nfv/trex && \
#    wget --no-cache --no-check-certificate https://trex-tgn.cisco.com/trex/release/${TREX_VER}.tar.gz && \
#    tar zxvf ${TREX_VER}.tar.gz && \
#    rm ${TREX_VER}.tar.gz

# install scapy
#RUN pip install scapy

########## OLD BUILD PATH WITH TREX ##########
