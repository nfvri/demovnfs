#NS = your docker namespace
export VERSION ?= 1.1.0

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

release: release-rllib-base

build: build-rllib-base

clean: clean-rllib-base
