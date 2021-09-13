-- SPDX-License-Identifier: BSD-3-Clause

package.path = package.path ..";?.lua;test/?.lua;app/?.lua;"

require "Pktgen"

-- Set the following settings according to your set up and testing
------------------------------------------------------------------
print("**** Execute Range test ********");

pktgen.range.dst_mac("0", "start", "76:c6:88:6e:34:0a");
-- pktgen.range.src_mac("0", "start", "3c:fd:fe:9c:5c:d8");

pktgen.range.src_ip("0", "start", "16.0.153.153");
pktgen.range.src_ip("0", "inc", "0.0.0.1");
pktgen.range.src_ip("0", "min", "16.0.153.153");
pktgen.range.src_ip("0", "max", "16.0.153.154");

pktgen.range.dst_ip("0", "start", "6.6.6.6");
pktgen.range.dst_ip("0", "inc", "0.0.0.1");
pktgen.range.dst_ip("0", "min", "6.6.6.6");
pktgen.range.dst_ip("0", "max", "6.6.6.7");

pktgen.set_proto("0", "udp");

-- pktgen.set("0", "sport", 42889);
-- pktgen.set("0", "dport", 42889);

pktgen.range.dst_port("0", "start", 0);
pktgen.range.dst_port("0", "inc", 1);
pktgen.range.dst_port("0", "min", 0);
pktgen.range.dst_port("0", "max", 1000);

pktgen.range.src_port("0", "start", 0);
pktgen.range.src_port("0", "inc", 1);
pktgen.range.src_port("0", "min", 0);
pktgen.range.src_port("0", "max", 1000);

pktgen.set("0", "size", 64);
-- pktgen.range.pkt_size("0", "start", 64);
-- pktgen.range.pkt_size("0", "inc", 0);
-- pktgen.range.pkt_size("0", "min", 64);
-- pktgen.range.pkt_size("0", "max", 256);

pktgen.set("all", "rate", 45)
pktgen.set_proto("all", "udp");

sendport = 0;
pktgen.set_range("0", "on");
pktgen.start(0)

file = '/full/path/to/traffic/pattern/file.txt'; -- A txt file in which each line has a traffic step (link rate).
time_step = 10;     -- (seconds) time interval between traffic steps
repeat_num = -1;    -- number of runs of traffic pattern. -1 for infinitive loop
------------------------------------------------------------------

-- Take two lists and create one table with a merged value of the tables.
-- Return a set or table = { { timo, rate }, ... }
function Set(step, list)
	local	set = { };		-- Must have a empty set first.

	for i,v in ipairs(list) do
		set[i] = { timo = step, rate = v };
	end

	return set;
end

-- see if the file exists
function file_exists(file)
	local f = io.open(file, "rb");
	if f then f:close() end
	return f ~= nil;
end

-- get all the lines from a file, returns an empty
-- list/table if the file does not exist
function lines_from(file)
	local lines = {};
	local count = 0;
	for line in io.lines(file) do
		count = count + 1;
		lines[#lines + 1] = tonumber(line);
	end
	return lines
end

total_time = 0;

function main()
	local sending = 0;

	if not file_exists(file) then
		printf("The traffic pattern file does not exist. Edit its full path in the script.")
		return
	end

	local lines = lines_from(file);
	if #lines < 1 then
		printf("The traffic pattern file should contain at least one traffic step.")
	end

	local trlst = Set(time_step, lines);

    loop = 1
    while true do
        if repeat_num ~= -1 and loop > repeat_num then
            break
        end
        loop = loop + 1;

		-- v is the table with the values created by the Set(x,y) function
		for idx,v in pairs(trlst) do
			-- Set the rate to the new value
			pktgen.set(sendport, "rate", v.rate);

			-- If not sending packets start sending them
			if ( sending == 0 ) then
				pktgen.start(sendport);
				sending = 1;
			end

			-- Sleep until we need to set the next rate value
			sleep(v.timo);
			total_time = total_time + v.timo;

			::continue::
		end
	end

	-- Stop the port and do some cleanup
	pktgen.stop(sendport);
	sending = 0;
end

printf("\n**** Traffic Profile***\n");
main();
printf("\n*** Traffic Profile Done (Total Time %d) ***\n", total_time);
