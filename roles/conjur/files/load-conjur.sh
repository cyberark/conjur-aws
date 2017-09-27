#!/bin/sh -ex

image="$CONJUR_IMAGE:$CONJUR_VERSION"
docker pull $image
docker tag $image conjur
