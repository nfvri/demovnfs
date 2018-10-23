#!/usr/bin/env bash
apt-get install -y gcc make wget
mkdir -p /vnf
wget https://dl.google.com/go/go1.9.3.linux-amd64.tar.gz -P /vnf
cd /vnf && tar zxvf /vnf/go1.9.3.linux-amd64.tar.gz
git clone https://github.com/nfvsap/simple-em /vnf/simple-em
cd /vnf/simple-em && /vnf/go/bin/go build 
git clone https://github.com/anastop/archbench /vnf/archbench
git clone https://github.com/anastop/util /vnf/util
cd /vnf/archbench/memory_tests && make
