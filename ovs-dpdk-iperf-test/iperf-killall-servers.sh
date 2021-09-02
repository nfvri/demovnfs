#!/bin/bash

for i in 2 4 6 8
do
	ssh ubuntu${i} "killall iperf3"
done

