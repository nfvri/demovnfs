#!/usr/bin/env bash
apt-get install -y gcc make wget build-essential libnuma-dev python-pip
mkdir -p /vnf
wget https://dl.google.com/go/go1.9.3.linux-amd64.tar.gz -P /vnf
cd /vnf && tar zxvf /vnf/go1.9.3.linux-amd64.tar.gz
git clone https://github.com/nfvsap/hist-em /vnf/hist-em
git clone git://git.kernel.org/pub/scm/utils/rt-tests/rt-tests.git /vnf/cyclictest
pip install numpy
cd /vnf/cyclictest && git checkout stable/v1.0 && make cyclictest
cp /vnf/cyclictest/cyclictest /vnf/hist-em
mkdir -p /vnf/go-work/src
cp -R /vnf/hist-em /vnf/go-work/src/
rm /vnf/go-work/src/hist-em/collector.go
cd /vnf/go-work/src/hist-em && GOPATH=/vnf/go-work/src /vnf/go/bin/go get ./...
cd /vnf/go-work/src/hist-em && GOPATH=/vnf/go-work/src /vnf/go/bin/go build
