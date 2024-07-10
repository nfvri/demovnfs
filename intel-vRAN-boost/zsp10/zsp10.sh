#!/bin/bash

source .env
echo "Experiment with one Core Network, $MAX_RAN RAN instances and multiple UEs is starting..."

docker-compose -f docker-compose-core-network.yaml up -d
echo 'Core Network: OK' 
sleep 5 
# docker network disconnect demo-oai-public-net $(docker service ls --filter name=lb-demo-oai-public-net -q)
# docker network connect --ip 192.168.70.2 demo-oai-public-net $(docker service ls --filter name=lb-demo-oai-public-net -q)


for (( id=$ID_START; id <=$MAX_RAN; id++ )); do
  docker-compose -f docker-compose-ran-$id.yaml up -d  
  echo "RAN $id: OK"
done

echo 'Do you want to see the all the log info? (y/n)'
read logs

if [[ $logs == 'n' ]]; then 
        exit 0
else
        echo 'Important logs for the experiment:'
        docker ps -a 
        echo 'Press enter to continue, press Ctrl+C to exit.'
        read next_logs
        
        echo '-------------------------------AMF LOGS-------------------------------------'
        docker logs oai-amf --tail 100 
        echo 'Press enter to continue, press Ctrl+C to exit.'
        read next_logs
fi

echo "Start grok exporter at http://zsp10:8000/metrics"
docker-compose -f docker-compose-grok-exporter.yml up -d 

echo "Start the bash script collect du-metrics from the container logs"
./collect-du-metrics.sh
