FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y python3 python3-pip curl stress-ng pciutils procps && \
    apt -y clean 

RUN mkdir /apps 

COPY entrypoint.sh /apps/entrypoint.sh

ENTRYPOINT bash -c \"sleep infinity\"

