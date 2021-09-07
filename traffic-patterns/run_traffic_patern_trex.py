import stl_path
from trex.stl.api import *
import pprint

import time
import os
import argparse


def run_traffic(streams_file, traffic_pattern_file, send_port):
    time_step = 5  # seconds

    # create client
    # verbose_level = 'high'
    c = STLClient(verbose_level='error')

    try:
        if not os.path.exists(streams_file):
            print(f"Streams file {streams_file} does not exist!")
            return
        if not os.path.exists(traffic_pattern_file):
            print(f"Traffic pattern file {traffic_pattern_file} does not exist!")
            return

        # connect to server
        c.connect()

        ports = [int(send_port)]

        # prepare the ports
        c.reset(ports=ports)

        print((" is connected: {0}".format(c.is_connected())))
        print((" number of ports: {0}".format(c.get_port_count())))
        print((" acquired_ports: {0}".format(c.get_acquired_ports())))
        # port stats
        print(c.get_stats(ports))

        # port info, mac-addr info, speed
        print(c.get_port_info(ports))

        lines = lines_from(traffic_pattern_file)
        if len(lines) < 1:
            print("The traffic pattern file should contain at least one traffic step.")
            return

        traffic = lines[0] if float(lines[0])!=0 else "0.00001"
        c.stop_line(f" --port {send_port} ")
        c.start_line(f" -f {streams_file} -m {traffic}% --port {send_port}")
        while 1:
            for line in lines:
                c.update_line(f"--port {send_port} -m {line if float(line)!=0 else '0.00001'}%")
                time.sleep(time_step)


    except STLError as e:
        print(e)

    finally:
        c.disconnect()


def lines_from(file):
    lines = []
    fp = open(file, "r")
    line = fp.readline()
    while line:
        lines.append(line.split("\n")[0])
        line = fp.readline()
    fp.close()
    return lines


if __name__ == '__main__':
    parser = argparse.ArgumentParser()

    parser.add_argument('--port', help='The port number to send the traffic.')
    parser.add_argument('--streams_file', help='The full path of the file with the traffic streams definitions.')
    parser.add_argument('--traffic_pattern_file', help='The full path of the traffic pattern file.'
                                                       ' A txt file in which each line has a traffic step (link rate).')

    args = parser.parse_args()

    if args.streams_file is None or args.streams_file == "":
        print("You should provide the full path of an existing file with the streams definitions.")
        exit(1)
    if args.traffic_pattern_file is None or args.traffic_pattern_file == "":
        print("You should provide the full path of an existing traffic pattern file.")
        exit(1)

    port = args.port if args.port is not None and args.port != "" else "0"

    run_traffic(args.streams_file, args.traffic_pattern_file, port)
