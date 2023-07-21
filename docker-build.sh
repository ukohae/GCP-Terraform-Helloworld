#!/bin/bash

project_id="gcp-terraform-env"
npm i --silent
gcloud auth activate-service-account gcp-test@gcp-terraform-env.iam.gserviceaccount.com --key-file=./creds/serviceaccount.json
gcloud auth print-access-token | docker login -u oauth2accesstoken --password-stdin https://gcr.io
echo $USER
sudo docker build . -t gcr.io/${project_id}/app
sudo docker push gcr.io/${project_id}/app
sudo docker rmi gcr.io/${project_id}/app
