#!/bin/bash 

source .env
#ID_START=16
#UE_START=4
#MAX_RAN=4
#MAX_UE=5


# the number 13 is missing because core network is deployed on IPs 192.168.70.[130-139]
ip_slots=(0 1 2 3 4 5 6 7 8 9 10 11 12 14 15 16 17 18 19 20 21)

for  (( id=$ID_START; id<=$MAX_RAN; id++ )); do
	ran_ip_slot=${ip_slots[$id]}
	echo "The IPs for these UEs are 192.168.70.$ran_ip_slot[3-$(( $MAX_UE+2 ))] attached to DU-$id " 
	for (( ue_num=$UE_START; ue_num<=$MAX_UE; ue_num++ )); do

		docker run -d --name oai-nr-ue-$id-$ue_num \
			--expose 36412 --expose 38462 --expose 2153 \
			--env TZ=UTC \
			--privileged \
			--network demo-oai-public-net \
			--ip 192.168.70.$ran_ip_slot$(( $ue_num+2 )) \
                        --cpuset-cpus="10-17,30-37" \
			-v $(pwd)/ran-conf/ue-$id-$ue_num.conf:/opt/oai-nr-ue/etc/nr-ue.conf oaisoftwarealliance/oai-nr-ue:v2.1.0 \
			/bin/bash -c "exec /opt/oai-nr-ue/bin/nr-uesoftmodem -O /opt/oai-nr-ue/etc/nr-ue.conf --sa --rfsim -r 106 --numerology 1 -C 3619200000 --nokrnmod --log_config.global_log_options level,nocolor,time --rfsimulator.serveraddr 192.168.70.$ran_ip_slot\2"
		echo "UE: oai-nr-ue-$id-$ue_num up"
	done
	sleep 2
done

