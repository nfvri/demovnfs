#NS = your docker namespace
export VERSION ?= latest

# For private repo
# export REPO = gcr.io/nfvsap
# For nfvri public repo
export REPO = nfvri

export NAME = stress-ng

.PHONY: build-stress-ng push-stress-ng rm-stress-ng

## Use cross-compilation by running:
##  docker run --privileged --rm tonistiigi/binfmt --install all
## Make sure you have enabled multibuilds (otherwise you are limited to one platform at a time!):
##  docker buildx create --name multibuilder --bootstrap --use
export BUILD_PLATFORMS = "linux/amd64,linux/arm64"

default: build

build-stress-ng:
	docker buildx build --platform $(BUILD_PLATFORMS) -t $(REPO)/$(NAME):$(VERSION) .

push-stress-ng:
	# For private repo
	#cat .gcloud_keyfile.json | docker login -u _json_key --password-stdin https://gcr.io
	# For public repo
	echo $(REPO_PAT) | base64 -d | docker login -u $(USERNAME) --password-stdin
	docker push $(REPO)/$(NAME):$(VERSION)

clean-stress-ng: 
	docker rmi -f $(REPO)/$(NAME):$(VERSION)

release-stress-ng: build-stress-ng push-stress-ng

release: release-stress-ng

build: build-stress-ng

clean: clean-stress-ng
