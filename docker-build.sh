#!/usr/bin/env bash

project_id="gcp-terraform-env"
npm i --silent
sudo -s
sudo docker build . -t gcr.io/${project_id}/app
gcloud auth activate-service-account gcp-test@gcp-terraform-env.iam.gserviceaccount.com --key-file=./creds/serviceaccount.json
gcloud auth print-access-token | sudo docker login -u oauth2accesstoken --password-stdin https://gcr.io
sudo docker push gcr.io/${project_id}/app
sudo docker rmi gcr.io/${project_id}/app

