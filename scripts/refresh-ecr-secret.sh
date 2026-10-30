#!/bin/bash
set -e
export PATH=$PATH:/usr/local/bin
TOKEN=$(aws ecr get-login-password --region ap-south-1)
k3s kubectl delete secret ecr-login -n staging --ignore-not-found
k3s kubectl create secret docker-registry ecr-login \
  --namespace staging \
  --docker-server=223767250051.dkr.ecr.ap-south-1.amazonaws.com \
  --docker-username=AWS \
  --docker-password="$TOKEN"
