#!/bin/bash
SECRETNAME=nfvsap-private-repo
kubectl create secret docker-registry $SECRETNAME --docker-server=https://gcr.io --docker-username=_json_key --docker-email=user@example.com --docker-password="$(cat k8s-gcr-auth-ro.json)"
kubectl -n kube-system create secret docker-registry $SECRETNAME --docker-server=https://gcr.io --docker-username=_json_key --docker-email=user@example.com --docker-password="$(cat k8s-gcr-auth-ro.json)"

kubectl patch serviceaccount default  -p "{\"imagePullSecrets\": [{\"name\": \"$SECRETNAME\"}]}"
