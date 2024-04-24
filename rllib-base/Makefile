#NS = your docker namespace
export VERSION ?= 2.3.1-2.10

# For private repo
# export REPO = gcr.io/nfvsap
# For nfvri public repo
export REPO = nfvri

export NAME = rllib-base

.PHONY: build-rllib-base push-rllib-base rm-rllib-base

default: build

build-rllib-base:
	docker build -t $(REPO)/$(NAME):$(VERSION) .

push-rllib-base:
	# For private repo
	#cat .gcloud_keyfile.json | docker login -u _json_key --password-stdin https://gcr.io
	# For public repo
	echo $(REPO_PAT) | base64 -d | docker login -u $(USERNAME) --password-stdin
	docker push $(REPO)/$(NAME):$(VERSION)

clean-rllib-base: 
	docker rmi -f $(REPO)/$(NAME):$(VERSION)

release-rllib-base: build-rllib-base push-rllib-base

build-multi-rllib-base:
	docker buildx build --platform linux/amd64,linux/arm64 -t $(REPO)/$(NAME):$(VERSION) .

push-multi-rllib-base:
	echo $(REPO_PAT) | base64 -d | docker login -u $(USERNAME) --password-stdin
	docker buildx build --push --platform linux/amd64,linux/arm64 -t $(REPO)/$(NAME):$(VERSION) .

clean-multi-rllib-base: 
	docker rmi -f $(REPO)/$(NAME):$(VERSION)

release-multi-rllib-base: build-multi-rllib-base push-multi-rllib-base

# Defaulting to multi-platform builds. To setup your env use:
## $ docker run --privileged --rm tonistiigi/binfmt --install all
## $ docker buildx create --name multibuilder --bootstrap --use
# See also: https://docs.docker.com/build/building/multi-platform/

# If you are running qemu-emulated builds, and you get the following error:
## Opening zip "/proc/self/exe": lseek(): Bad file descriptor
# try:
## $ docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

release: release-multi-rllib-base

build: build-multi-rllib-base

clean: clean-multi-rllib-base

