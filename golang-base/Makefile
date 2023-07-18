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

release: release-golang-base

build: build-golang-base

clean: clean-golang-base
