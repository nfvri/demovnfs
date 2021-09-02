#!/bin/bash

./iperf-killall-servers.sh

for i in 2 4 6 8
do
	ssh ubuntu${i} "LD_LIBRARY_PATH=/home/ubuntu nohup /home/ubuntu/iperf3 -s > /var/log/iperf3-server" \
		2>&1| awk "{ print \"\\033[3$i;1;1mubuntu$i:\\033[0m \" \$0; }"&
done

