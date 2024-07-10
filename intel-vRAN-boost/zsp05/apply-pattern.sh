#!/bin/bash

# params
source .env
max_id=$MAX_RAN
max_container=$(( $MAX_RAN*$MAX_UE ))
#slot=$SLOT_START


# create the list with me available containers based on the .env file values
for (( id=$ID_START; id<=$MAX_RAN; id++ ));
do
  for (( ue_num=1; ue_num<=$MAX_UE; ue_num++ )); 
  do 
    container_list+=("oai-nr-ue-$id-$ue_num")
  done
done

echo "The list with the deployed containers"
echo ${container_list[@]}

# This func checks if a container is running
running_container() {
    local container_name=$1

    if docker ps | grep -q "$container_name"; then 
    	echo "Running: $container_name"
	return 0 # True (running) # normal output
    else 
	echo "Not Running: $container_name"
    	return 1 # False (not running) # problematic output
    fi
}

# This func counts the running ue containers 
count_container() {
    count=$(docker ps | grep "oai-nr-ue-" | wc -l)
    echo $count
} 


# This func increases the index of the container_list available 
# returns the counter mod max_container for in range values
fix_index() {
    local index=$1
    (( index++ ))
    echo $(( $index%max_container ))
}

# initilize 
index=0
# main func
while true; do
	for line in $(cat pattern-diurnal.txt);
	do 
		current_ues=$(count_container)
		next_ues=$(( $line*$max_container/100 ))
		echo "" 
		echo "STATE: current_ues=$current_ues, next_ues=$next_ues"
		echo "We will be in the 0,$line% cappacity of the network"
		echo ""
	
		if [[ $current_ues -eq $next_ues ]]; then 
			echo "Fixed $current_ues containers"
		elif [[ $current_ues -lt $next_ues ]]; then
	                j=1
			num_to_open=$(( $next_ues - $current_ues ))
			echo "Open $next_ues - $current_ues = $num_to_open containers"
			
	                while [[ $j -le $num_to_open ]]
	                do
	                    while running_container ${container_list[$index]}; do
				index=$(fix_index $index)
			    done
	 
	                    docker start ${container_list[$index]} && echo "opened: ${container_list[$index]}"
	                    (( j++ ))
	                    index=$(fix_index $index)
	                done
		elif [[ $current_ues -gt $next_ues ]]; then
	                j=1
			num_to_close=$(( $current_ues - $next_ues ))
			echo "Close $current_ues - $next_ues = $num_to_close containers"
	
	                while [[ $j -le $num_to_close ]]
	                do 
	                    if running_container ${container_list[$index]}; then
	                        docker kill ${container_list[$index]} && echo "closed: ${container_list[$index]}"
	                        (( j++ ))
	                    fi
	                    index=$(fix_index $index)
	                done
	 	fi
		# Waiting time between next pattern's value
		sleep 1
	done
done

