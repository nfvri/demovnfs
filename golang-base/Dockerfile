FROM debian:bullseye
RUN apt-get update \
 && apt-get -y install git golang make gcc bzr libvirt-dev linux-headers-amd64 libbpfcc libbpfcc-dev bpfcc-tools 

# Replicate paths from golang image
ENV GOPATH /go
ENV PATH $GOPATH/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
WORKDIR $GOPATH
