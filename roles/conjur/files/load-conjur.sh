#!/bin/sh -ex

docker login -u $REGISTRY_USER -p $REGISTRY_PASSWORD $REGISTRY
docker pull $CONJUR_IMAGE
docker tag $CONJUR_IMAGE conjur
