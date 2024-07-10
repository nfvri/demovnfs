#!/bin/bash 

source .env
#ID_START=1
#UE_START=1
#MAX_RAN=10
#MAX_UE=4
# Replace following line with one of the lines below to kill/start/stop container and not just remove
# docker rm -f oai-nr-ue-$id-$ue_num 
# docker kill oai-nr-ue-$id-$ue_num 
# docker stop  oai-nr-ue-$id-$ue_num 
# docker start oai-nr-ue-$id-$ue_num 

for (( id=$ID_START; id<=$MAX_RAN; id++ )); do 
	echo "id: $id"
	for (( ue_num=$UE_START; ue_num<=$MAX_UE; ue_num++ )); do
		docker rm -f oai-nr-ue-$id-$ue_num 
		echo "ue: oai-nr-ue-$id-$ue_num"
	done
done

