#!/bin/bash
npm i --silent
docker build . -t gcr.io/terraform-project-100/app
docker push gcr.io/terraform-project-100/app
docker rmi gcr.io/terraform-project-100/app
