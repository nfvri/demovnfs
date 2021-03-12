#NS = your docker namespace
export VERSION ?= v21.02

# For private repo
# export REPO = gcr.io/nfvsap
# For nfvri public repo
export REPO = nfvri

export NAME = dpdk-ubuntu-testpmd

.PHONY: build-dpdk push-dpdk rm-dpdk

default: build

build-dpdk:
	docker build -f Dockerfile-v21.02 --build-arg DPDK_VER=$(VERSION) -t $(REPO)/$(NAME):$(VERSION) .

push-dpdk:
	# For private repo
	#cat .gcloud_keyfile.json | docker login -u _json_key --password-stdin https://gcr.io
	# For public repo
	echo $(REPO_PAT) | base64 -d | docker login -u $(USERNAME) --password-stdin
	docker push $(REPO)/$(NAME):$(VERSION)

clean-dpdk: 
	docker rmi -f $(REPO)/$(NAME):$(VERSION)

release-dpdk: build-dpdk push-dpdk

release: release-dpdk

build: build-dpdk

clean: clean-dpdk
