#NS = your docker namespace
export VERSION ?= 20.04

# For private repo
# export REPO = gcr.io/nfvsap
# For nfvri public repo
export REPO = nfvri

export NAME = cache-sensitive

.PHONY: build-cache-sensitive push-cache-sensitive rm-cache-sensitive

default: build

build-cache-sensitive:
	docker build -t $(REPO)/$(NAME):$(VERSION) .

push-cache-sensitive:
	# For private repo
	#cat .gcloud_keyfile.json | docker login -u _json_key --password-stdin https://gcr.io
	# For public repo
	echo $(REPO_PAT) | base64 -d | docker login -u $(USERNAME) --password-stdin
	docker push $(REPO)/$(NAME):$(VERSION)

clean-cache-sensitive: 
	docker rmi -f $(REPO)/$(NAME):$(VERSION)

release-cache-sensitive: build-cache-sensitive push-cache-sensitive

release: release-cache-sensitive

build: build-cache-sensitive

clean: clean-cache-sensitive
