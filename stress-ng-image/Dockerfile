FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN echo "Acquire::http::Proxy \"http://icache.intracomtel.com:80/\";" > /etc/apt/apt.conf.d/proxy.conf && \
    apt-get update && \
    apt-get install -y curl stress-ng pciutils procps && \
    apt -y clean && \
    rm -fr /etc/apt/apt.conf.d/proxy.conf

RUN mkdir /apps 

COPY entrypoint.sh /apps/entrypoint.sh

ENTRYPOINT bash -c \"sleep infinity\"

