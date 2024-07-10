#!/bin/bash

source .env

#ID_START=19
#MAX_RAN=9

id=$ID_START 
#for (( id=$ID_START; id<=$MAX_RAN; id++ )); do
for  slot in 1 2 3 4 5 6 7 8 9 10 11 12 14 15 16 17 18 19 20 21; do 
  touch docker-compose-ran-$id.yaml
   
  sed \
  -e s/@ID@/$id/g \
  -e s/@AMF_IP@/192.168.70.132/g \
  -e s/@CUCP_IP@/192.168.70.$slot\0/g \
  -e s/@CUUP_IP@/192.168.70.$slot\1/g \
  -e s/@DU_IP@/192.168.70.$slot\2/g \
  docker-compose-scale-ran.yaml > docker-compose-ran-$id.yaml
  
  echo 'docker-compose RAN with id:'$id' is creted'

  (( id++ ))

done





