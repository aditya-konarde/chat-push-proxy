#!/bin/bash

# Show command before executing
set -x

# Exit on error
set -e

export BUILD_TIMESTAMP=`date -u +%Y-%m-%dT%H:%M:%S`+00:00

# Check the existence of image on registry.centos.org
IMAGE="mattermost-push-proxy"
REGISTRY="https://registry.centos.org"
REPOSITORY="mattermost"
TEMPLATE="openshift/mattermost-push-proxy.app.yaml"

#Find tag used by deployment template
echo -e "Scanning OpenShift Deployment Template for Image tag"
TAG=$(cat $TEMPLATE | grep -o -e "registry.*" | awk '{split($0,array,"/")} END{print array[3]}' | awk '{split($0,array,":")} END{print array[2]}')

#Check if image is in the registry
echo -e "Checking if image exists on the registry"
TAGLIST=$(curl -X GET $REGISTRY/v2/$REPOSITORY/$IMAGE/tags/list)
echo $TAGLIST | grep -w $TAG

if [ $? -eq 0 ]; then
  echo 'CICO: Image existence check successful. Ready to deploy updated app'
  exit 0
else
  echo 'CICO: Image existence check failed. Exiting'
  exit 2
fi
