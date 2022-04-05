#!/bin/bash
npm i --silent
docker build . -t gcr.io/cellular-dream-342220/app
docker push gcr.io/cellular-dream-342220/app
docker rmi gcr.io/cellular-dream-342220/app
