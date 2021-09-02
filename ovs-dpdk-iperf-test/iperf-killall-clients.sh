#!/bin/bash

for i in 1 3 5 7
do
	ssh ubuntu${i} "killall iperf3"
done

