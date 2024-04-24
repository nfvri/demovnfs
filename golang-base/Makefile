#NS = your docker namespace
export VERSION ?= bookworm-1.20.6-2.10.0

# For private repo
# export REPO = gcr.io/nfvsap
# For nfvri public repo
export REPO = nfvri

export NAME = golang-base

.PHONY: build-golang-base push-golang-base rm-golang-base

default: build

build-golang-base:
	docker build -t $(REPO)/$(NAME):$(VERSION) .

push-golang-base:
	# For private repo
	#cat .gcloud_keyfile.json | docker login -u _json_key --password-stdin https://gcr.io
	# For public repo
	echo $(REPO_PAT) | base64 -d | docker login -u $(USERNAME) --password-stdin
	docker push $(REPO)/$(NAME):$(VERSION)

clean-golang-base: 
	docker rmi -f $(REPO)/$(NAME):$(VERSION)

release-golang-base: build-golang-base push-golang-base

build-multi-golang-base:
	docker buildx build --platform linux/amd64,linux/arm64 -t $(REPO)/$(NAME):$(VERSION) .

push-multi-golang-base:
	echo $(REPO_PAT) | base64 -d | docker login -u $(USERNAME) --password-stdin
	docker buildx build --push --platform linux/amd64,linux/arm64 $(REPO)/$(NAME):$(VERSION)

clean-multi-golang-base: 
	docker rmi -f $(REPO)/$(NAME):$(VERSION)

release-multi-golang-base: build-multi-golang-base push-multi-golang-base

# Defaulting to multi-platform builds. To setup your env use:
## $ docker run --privileged --rm tonistiigi/binfmt --install all
## $ docker buildx create --name multibuilder --bootstrap --use
# See also: https://docs.docker.com/build/building/multi-platform/

# If you are running qemu-emulated builds, and you get the following error:
## Opening zip "/proc/self/exe": lseek(): Bad file descriptor
# try:
## $ docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

release: release-multi-golang-base

build: build-multi-golang-base

clean: clean-multi-golang-base
