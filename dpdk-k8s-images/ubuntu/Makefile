#NS = your docker namespace
export VERSION ?= v20.08

# For private repo
# export REPO = gcr.io/nfvsap
# For public repo
export REPO = ghcr.io/angelouev/public
export REPO_PAT = ZDY5YzQ1NTQyZjUxMmNkYjg2Zjk5NWI2M2M3Y2QwOWYxYWRiMjk5Ywo=
export USERNAME = angelouev
# For nfvsap public repo
#export REPO = ghcr.io/nfvsap/public
#export REPO_PAT = 4ffa630ead7e5c97bc3604d1410a9b138bcada94
#export USERNAME = nfvsap

export NAME = dpdk-ubuntu-testpmd

.PHONY: build-dpdk push-dpdk rm-dpdk

default: build

build-dpdk:
	docker build --build-arg DPDK_VER=$(VERSION) -t $(REPO)/$(NAME):$(VERSION) .

push-dpdk:
	# For private repo
	#cat .gcloud_keyfile.json | docker login -u _json_key --password-stdin https://gcr.io
	# For public repo
	echo $(REPO_PAT) | base64 -d | docker login ghcr.io -u $(USERNAME) --password-stdin
	docker push $(REPO)/$(NAME):$(VERSION)

clean-dpdk: 
	docker rmi -f $(REPO)/$(NAME):$(VERSION)

release-dpdk: build-dpdk push-dpdk

release: release-dpdk

build: build-dpdk

clean: clean-dpdk
