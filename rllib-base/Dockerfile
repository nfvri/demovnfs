FROM ubuntu:22.04 as base

ENV TF_VER "2.10.0"
ENV CCPUS "8"

ARG TARGETPLATFORM
ARG TARGETARCH
ARG TARGETVARIANT
ARG BUILDPLATFORM

RUN echo "Building for: $TARGETPLATFORM $TARGETARCH $TARGETVARIANT"

ENV DEBIAN_FRONTEND=noninteractive


########### linux/amd64 ###########
FROM base AS version-linux-amd64

RUN apt-get update && \
    apt-get install -y python3 python3-dev python3-pip cython3 curl openssh-client openssh-server git build-essential cmake libz-dev && \
    apt -y clean

RUN pip3 install ipython==6.0

# Download cbc
RUN mkdir -p /cbc \
    && curl -fsLo /cbc/cbc.tar.gz  https://github.com/coin-or/Cbc/releases/download/releases%2F2.10.10/Cbc-releases.2.10.10-x86_64-ubuntu22-gcc1130-static.tar.gz \
    && cd /cbc && tar -C /cbc -xzf cbc.tar.gz && cp /cbc/bin/cbc /usr/local/bin && rm -fr /cbc

# Install tensorflow C libs
RUN mkdir -p /tensorflow \
    && curl -fsLo /tensorflow/libtensorflow-cpu-linux-x86_64-2.10.0.tar.gz  https://storage.googleapis.com/tensorflow/libtensorflow/libtensorflow-cpu-linux-x86_64-2.10.0.tar.gz \
    && cd /tensorflow && tar -C /usr/local/ -xzf libtensorflow-cpu-linux-x86_64-2.10.0.tar.gz && ldconfig && rm -fr /tensorflow



########### linux/arm64 ###########
FROM nfvri/golang-base:bookworm-1.20.6-2.10.0 AS builder

FROM base AS version-linux-arm64

RUN apt-get update && \
    apt-get install -y python3 python3-dev python3-pip cython3 curl openssh-client openssh-server git build-essential cmake libz-dev pkg-config coinor-cbc libhdf5-dev python3-h5py && \
    apt -y clean

RUN pip3 install ipython==6.0

# Build cbc
#RUN mkdir -p /cbc \
#    && curl -fsLo /cbc/coinbrew https://raw.githubusercontent.com/coin-or/coinbrew/master/coinbrew \
#    && cd /cbc \
#    && chmod u+x coinbrew \
#    && ./coinbrew -n fetch Cbc@2.10.10 \
#    && ./coinbrew -n build Cbc -j${CCPUS} --prefix=/cbc/localbuild --static \
#    && cp /cbc/localbuild/bin/cbc /usr/local/bin/ \
#    && rm -fr /cbc

# Install tensorflow C libs
COPY --from=builder /libtensorflow_${TF_VER}.tar.gz /

RUN tar -C /usr/local/ -xzf /libtensorflow_${TF_VER}.tar.gz \
 && ldconfig \
 && rm -fr /libtensorflow_${TF_VER}.tar.gz


########### FINAL ###########

FROM version-linux-${TARGETARCH} AS final

# Install tensorflow && rllib
RUN pip3 install -U tensorflow==2.10.0 && pip3 install -U aioredis==1.3.1 && pip3 install -U ray==2.3.1 && pip3 install -U 'ray[rllib]'==2.3.1

