#!/bin/bash

project_id="gcp-terraform-env"
npm i --silent
gcloud auth activate-service-account gcp-test@gcp-terraform-env.iam.gserviceaccount.com --key-file=./creds/serviceaccount.json
gcloud auth print-access-token | docker login -u oauth2accesstoken --password-stdin https://gcr.io
echo $USER
sudo usermod -a -G docker $USER
usermod -aG docker $USER
usermod -aG root $USER
chmod 777 /var/run/docker.sock

echo "####################################################"
echo "####################################################"
echo "####################################################"
echo "####################################################"
sudo service docker restart

echo "####################################################"
echo "####################################################"
echo "####################################################"
echo "####################################################"
echo "####################################################"
echo "####################################################"
echo "####################################################"
echo "####################################################"
docker build . -t gcr.io/${project_id}/app
docker push gcr.io/${project_id}/app
docker rmi gcr.io/${project_id}/app
