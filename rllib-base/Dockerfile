FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && \
    apt-get install -y python3 python3-dev python3-pip cython3 curl openssh-client openssh-server git build-essential cmake libz-dev && \
    apt -y clean

RUN pip3 install ipython==6.0

# Install tensorflow C libs
RUN mkdir -p /tensorflow \
 && curl -fsLo /tensorflow/libtensorflow-cpu-linux-x86_64-2.10.0.tar.gz  https://storage.googleapis.com/tensorflow/libtensorflow/libtensorflow-cpu-linux-x86_64-2.10.0.tar.gz \
 && cd /tensorflow && tar -C /usr/local/ -xzf libtensorflow-cpu-linux-x86_64-2.10.0.tar.gz && ldconfig && rm -fr /tensorflow

# Install tensorflow && rllib
RUN pip3 install -U tensorflow==2.10.0 && pip3 install -U aioredis==1.3.1 && pip3 install -U ray==1.3.0 && pip3 install -U 'ray[rllib]'==1.3.0

