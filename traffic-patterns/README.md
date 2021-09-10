# Traffic Patterns

## Creation of a traffic pattern

The first of running a traffic pattern is the creation of a simple txt file with the
traffic pattern. To create this file you can use the script `traffic_rate_creator.py`
or by any other means of your choice. The file should contain the traffic steps in
link rate (%). Each line should be a traffic step.

Note that the more traffic steps the more detailed pattern but the longer time of
running the pattern.

To run the script:
```console
python3 traffic_rate_creator.py
```

The output will be two files, one txt file with the traffic pattern (like
`example-traffic-rate-pattern.txt`) and one image with the graphic representation
of the traffic pattern (like `example-traffic-rate-pattern.png`).

To modify some attributes of the pattern you can run:
```console
python3 traffic_rate_creator.py --number_of_steps=100 --low_load=0 --high_load=40 --plot_file=/path/to/example.png --traffic_pattern_file=/path/to/example.txt
```

The `number_of_steps` is the number of the total traffic steps that the pattern will have.
The `low_load` is the lowest traffic level (in rate) of the pattern.
The `high_load` is the highest traffic level (in rate) of the pattern.
The `plot_file` is the full path where the plot file will be stored.
The `traffic_pattern_file` is the full path where the txt file will be stored.

In case you want to change more attributes of the traffic pattern you can edit the script.
If you want to specify the exact number of step to start the rise of the pattern, to end
the rise or to end the downtrend you can change the values of start_of_rise, end_of_rise,
end_of_downtrend respectively. For example, for start_of_rise=10, end_of_rise=50,
end_of_downtrend=90 and:
```console
python3 traffic_rate_creator.py --number_of_steps=100 --low_load=0 --high_load=40 --plot_file=./example-traffic-rate-pattern-modified.png --traffic_pattern_file=./example-traffic-rate-pattern-modified.txt
```
You can see the traffic pattern in the aforementioned files.

There are also some more complex traffic patterns (large, medium, small) as examples.
They were not produced by the script but represent a traffic pattern during a day.

## Run traffic pattern through T-rex

To run the traffic pattern through traffic generator T-rex you need two files, one with 
the traffic pattern (as mentioned in section `Creation of a traffic pattern`) and one with
the streams definition (like `udp_1pkt_simple.py`).

You need to have the Trex up and running and before running the script
`run_traffic_pattern_trex.py` you should export the paths:
```console
export PYTHONPATH=/your/path/to/trex/automation/trex_control_plane/interactive/trex/:$PYTHONPATH

export PYTHONPATH=/your/path/to/trex/automation/trex_control_plane/interactive/trex/examples/stl:$PYTHONPATH
```

Then run:
```console
python3 run_traffic_pattern_trex.py --streams_file=./udp_1pkt_simple.py --traffic_pattern_file=./traffic_pattern.txt --port=0
```

The port argument is the port id to start the traffic.
Each traffic step in the `traffic_pattern.txt` will be applied for 10 seconds. If you want
to change the time step you should edit the script. The traffic pattern will be applied
infinitively until you stop the script.

## Run traffic pattern through Pktgen

To run the traffic pattern through traffic generator pktgen you need one files with the
traffic pattern (as mentioned in section `Creation of a traffic pattern`).

You need to have built the pktgen and edit the script `run_traffic_pattern_pktgen.lua` 
to change its settings according to your set up and testing purposes (e.g. file path
of traffic pattern, mac addresses, packet size, port id etc).

Then run pktgen with the script as argument. For example:
```console
./Builddir/app/pktgen -l 20,22,24 -w 0000:3b:02.0 -w 0000:3b:0a.0 -- -m'22.0, 24.1' -f /pktgen_configs/run_traffic_pattern_pktgen.lua
```

Each traffic step in the `traffic_pattern.txt` will be applied for 10 seconds. If you want
to change the time step you should edit the script. The traffic pattern will be applied
infinitively until you stop the script. If you want to run the traffic pattern for a specified
number of times, you should edit the `repeat_num` option in the script.
