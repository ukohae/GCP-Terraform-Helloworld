#!/bin/bash

project_id=""
npm i --silent
docker build . -t gcr.io/${project_id}/app
docker push gcr.io/${project_id}/app
docker rmi gcr.io/${project_id}/app
