# Run 2 Upf-epcs with their own access and core traffic

In one server (e.g. clx2) run the 2 upfs, one premium upf and one normal. First set the VFs of the network cards and
change the nics/vfs names, macs if needed in docker_setup.sh script and upf_premium.json, upf_normal.json configurations.

Run the script docker_setup.sh to launch the two upfs.
Note that the normal upf needs a modified image for bess, where the PFCPPort should be 8806 instead of 8805 in file pfcpiface/conn.go
(https://github.com/omec-project/upf-epc/blob/master/pfcpiface/conn.go#L19)

After the containers have started, add the rules in each bess container using the following commands:
```
docker exec pfcpiface-premium-bess pfcpiface -config /conf/upf_premium.json -simulate create
docker exec pfcpiface-normal-bess pfcpiface -config /conf/upf_normal.json -bess localhost:10515 -simulate create
```
To verify that the setup is right, check the pipelines in a broswer at 8000 and 8001 ports of clx2.

Then set the VFs of the network cards on the other server (clx1) and change the nics/vfs names, macs if needed
in pktgen-docker-setup.sh script and pktgen-*.bess configurations.

To start the pktgen containers and start sending traffic to both upfs run the pktgen-docker-setup.sh.

In the pktgen-docker-setup.sh there are commands like: 
```
docker exec pktgen-premium-access ./bessctl run pktgen-premium-access &
```
that start the traffic that has been configured in the configuration pktgen-premium-access.bess. To change some
attributs like the used traffic pattern file, pkt size etc you shoud edit this configuration. To start static traffic and not
a traffic pattern you can use the pktgen-*-static.bess configurations.

Verify that the traffic is received and goes through all the pipelines steps.

For more info check https://nfvri.atlassian.net/wiki/spaces/IN/pages/405143562/5G+UPFs#OMEC-UPF-EPC and https://github.com/omec-project/upf-epc
