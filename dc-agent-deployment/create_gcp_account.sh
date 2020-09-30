#!/bin/bash
# create a GCP service account; format of account is email address
SA_EMAIL=$(gcloud iam service-accounts --format='value(email)' create k8s-gcr-auth-ro)
# create the json key file and associate it with the service account
gcloud iam service-accounts keys create k8s-gcr-auth-ro.json --iam-account=$SA_EMAIL
# get the project id
PROJECT=$(gcloud config list core/project --format='value(core.project)')
# add the IAM policy binding for the defined project and service account
gcloud projects add-iam-policy-binding $PROJECT --member serviceAccount:$SA_EMAIL --role roles/storage.objectViewer
