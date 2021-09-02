#!/bin/bash

./iperf-killall-clients.sh

threads=${1:-'128'}
bitrate=${2:-'0'}

for i in 1 3 5 7
do
	server=$(echo "1+${i}" | bc)
	cmd="LD_LIBRARY_PATH=/home/ubuntu nohup /home/ubuntu/iperf3 -c 172.2.2.10${server} -t 3600 -u -P ${threads} -b ${bitrate} > /var/log/iperf3-client"
	export sshcmd="ssh ubuntu${i} '${cmd}' 2>&1| awk '{ print \"\\033[3${i};1;1mubuntu${i}:\\033[0m \" \$0; }'"
	/bin/sh -c "${sshcmd}" &
done

