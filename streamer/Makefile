#NS = your docker namespace
export VERSION ?= 20.04

# For private repo
# export REPO = gcr.io/nfvsap
# For nfvri public repo
export REPO = nfvri

export NAME = streamer

.PHONY: build-streamer push-streamer rm-streamer

default: build

build-streamer:
	docker build -t $(REPO)/$(NAME):$(VERSION) .

push-streamer:
	# For private repo
	#cat .gcloud_keyfile.json | docker login -u _json_key --password-stdin https://gcr.io
	# For public repo
	echo $(REPO_PAT) | base64 -d | docker login -u $(USERNAME) --password-stdin
	docker push $(REPO)/$(NAME):$(VERSION)

clean-streamer: 
	docker rmi -f $(REPO)/$(NAME):$(VERSION)

release-streamer: build-streamer push-streamer

release: release-streamer

build: build-streamer

clean: clean-streamer
