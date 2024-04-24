FROM golang:1.20.6-bookworm as base

ENV TF_VER "2.10.0"
ENV CCPUS "8"

ARG TARGETPLATFORM
ARG TARGETARCH
ARG TARGETVARIANT
ARG BUILDPLATFORM

RUN echo "Building for: $TARGETPLATFORM $TARGETARCH $TARGETVARIANT"

########### linux/amd64 ###########
FROM base AS version-linux-amd64
RUN apt-get update \
 && apt-get -y install bzr libvirt-dev linux-headers-amd64 python3 swig python3-numpy python3-distutils protobuf-compiler curl gnupg ipmitool \
                       bison build-essential cmake flex git libelf-dev libfl-dev libedit-dev libllvm14 llvm-14-dev libpolly-14-dev libclang-14-dev libclang-rt-14-dev \
                       dh-python zlib1g-dev arping bison clang-format cmake \
                       dpkg-dev pkg-kde-tools ethtool flex inetutils-ping iperf \
                       libbpf-dev libclang-dev libclang-cpp-dev libedit-dev libelf-dev \
                       libfl-dev libzip-dev linux-libc-dev llvm-dev libluajit-5.1-dev \
                       luajit python3-netaddr python3-pyroute2 python3-distutils python3 \
 && apt clean

# Install bazel
RUN curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > bazel.gpg \
 && mv bazel.gpg /etc/apt/trusted.gpg.d/ \
 && echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list \
 && apt-get -y update && apt-get -y install bazel && apt clean

# Compile and install bcc
RUN git clone --depth 1 --branch v0.24.0 https://github.com/iovisor/bcc.git && \
    mkdir ./bcc/build && \
    cd ./bcc/build && \
    cmake .. && \
    make -j${CCPUS} && \
    make install && \
    cd / && \
    rm -rf /bcc

# Install tensorflow C libs
RUN mkdir -p /tensorflow \
 && curl -fsLo /tensorflow/libtensorflow-cpu-linux-x86_64-${TF_VER}.tar.gz  https://storage.googleapis.com/tensorflow/libtensorflow/libtensorflow-cpu-linux-x86_64-${TF_VER}.tar.gz \
 && cd /tensorflow && tar -C /usr/local/ -xzf libtensorflow-cpu-linux-x86_64-${TF_VER}.tar.gz && ldconfig && rm -fr /tensorflow

########### linux/arm64 ###########
FROM base AS version-linux-arm64
RUN apt-get update \
 && apt-get -y install bzr libvirt-dev linux-headers-arm64 python3 swig python3-numpy python3-distutils protobuf-compiler curl gnupg ipmitool \
                       bison build-essential cmake flex git libelf-dev libfl-dev libedit-dev libllvm14 llvm-14-dev libpolly-14-dev libclang-14-dev libclang-rt-14-dev \
                       dh-python zlib1g-dev arping bison clang-format cmake \
                       dpkg-dev pkg-kde-tools ethtool flex inetutils-ping iperf \
                       libbpf-dev libclang-dev libclang-cpp-dev libedit-dev libelf-dev \
                       libfl-dev libzip-dev linux-libc-dev llvm-dev libluajit-5.1-dev \
                       luajit python3-netaddr python3-pyroute2 python3-distutils python3 \
 && apt clean

# Install bazel
#RUN curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > bazel.gpg \
# && mv bazel.gpg /etc/apt/trusted.gpg.d/ \
# && echo "deb [arch=arm64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | tee /etc/apt/sources.list.d/bazel.list \
# && apt-get -y update && apt-get -y install bazel && apt clean

RUN curl -fsLo /bazelisk-linux-arm64 https://github.com/bazelbuild/bazelisk/releases/download/v1.17.0/bazelisk-linux-arm64 \
 && chmod +x /bazelisk-linux-arm64 && mv /bazelisk-linux-arm64 /usr/local/bin/bazel

# Compile and install bcc
RUN git clone --depth 1 --branch v0.24.0 https://github.com/iovisor/bcc.git && \
    mkdir ./bcc/build && \
    cd ./bcc/build && \
    cmake .. && \
    make -j${CCPUS} && \
    make install && \
    cd / && \  
    rm -rf /bcc

# Install tensorflow C libs
#RUN mkdir -p /tensorflow \
# && curl -fsLo /tensorflow/libtensorflow-cpu-linux-x86_64-${TF_VER}.tar.gz  https://storage.googleapis.com/tensorflow/libtensorflow/libtensorflow-cpu-linux-x86_64-${TF_VER}.tar.gz \
# && cd /tensorflow && tar -C /usr/local/ -xzf libtensorflow-cpu-linux-x86_64-${TF_VER}.tar.gz && ldconfig && rm -fr /tensorflow

# Build tensorflow C libs
RUN mkdir -p /tensorflow \
 && curl -fsLo /tensorflow/v${TF_VER}.tar.gz https://github.com/tensorflow/tensorflow/archive/refs/tags/v${TF_VER}.tar.gz \
 && cd /tensorflow && tar zxf v${TF_VER}.tar.gz && cd tensorflow-${TF_VER} \
 && ./configure && bazel build --jobs 20 --config opt //tensorflow/tools/lib_package:libtensorflow

RUN cd /tensorflow/tensorflow-${TF_VER}/ && bazel build --jobs 20 --config opt //tensorflow/tools/lib_package:libtensorflow

RUN find / -name *libtensorflow.tar.gz* \
 && cp /tensorflow/tensorflow-${TF_VER}/bazel-bin/tensorflow/tools/lib_package/libtensorflow.tar.gz /libtensorflow_${TF_VER}.tar.gz \
 && tar -C /usr/local/ -xzf /libtensorflow_${TF_VER}.tar.gz \
 && ldconfig \
 && rm -fr /tensorflow

########### FINAL ###########


FROM version-linux-${TARGETARCH} AS final

# Replicate paths from golang image
ENV GOPATH /go
ENV PATH $GOPATH/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
WORKDIR $GOPATH
