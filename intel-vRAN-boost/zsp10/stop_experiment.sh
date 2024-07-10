#!/bin/bash

source .env

echo 'Shut Down the 5G Network'


#for (( id=$ID_START; id<=$MAX_RAN; id++ )); do
#  echo "id: $id"
#  for (( ue_num=1; ue_num<=$MAX_UE; ue_num++ )); do
#    docker stop oai-nr-ue-$id-$ue_num # && docker rm oai-nr-ue-$id-$ue_num
#    echo "ue: nr-ue-$id-$ue_num down"
#  done
#done

docker-compose -f docker-compose-grok-exporter.yml down

id=$ID_START
while [[ $id -le $MAX_RAN ]]
do
  docker-compose -f docker-compose-ran-$id.yaml down 
  echo "RAN $id: down"
  (( id++ ))
done


echo "Are you sure you want to shut down Core Network ? (y/n)"
read next
if [[ $next == 'y' ]]; then 
  docker-compose -f docker-compose-core-network.yaml down
  echo 'Core Network: down' 
fi

echo 'Nice!'
docker ps -a 
