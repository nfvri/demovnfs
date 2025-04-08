#!/bin/bash

VERSION=0.6.5

# Clone version
git clone -b v${VERSION} --single-branch https://github.com/ollama/ollama.git

# Use modified Dockerfile
cp Dockerfile ollama/
cd ollama/

# Make sure you have logged in (e.g. with docker login)
docker buildx build --push --platform linux/amd64 -t nfvri/ollama:${VERSION}-24.04 .

# Cleanup
cd ..
rm -fr ./ollama 
