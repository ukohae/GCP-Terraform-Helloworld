#!/usr/bin/env bash

project_id="gcp-terraform-env"
npm i --silent
sudo docker build . -t gcr.io/${project_id}/app
gcloud auth print-access-token | sudo docker login -u oauth2accesstoken --password-stdin https://gcr.io
sudo docker push gcr.io/${project_id}/app
sudo docker rmi gcr.io/${project_id}/app
