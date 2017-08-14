#!/bin/bash -ex

docker build -t ansible-boto .

name=conjur
version=0.1.0-stable
image=quay.io/conjur/${name}:${version}
tarball=${name}_${version}.tar.gz

docker run -i --rm \
  -e CONJUR_VERSION=$version \
  -e CONJUR_IMAGE=$image \
  -e CONJUR_TARBALL=$tarball \
  -e REGISTRY \
  -e REGISTRY_USER \
  -e REGISTRY_PASSWORD \
  -e AWS_REGION \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  -v $SSH_KEY:/root/.ssh/id_rsa \
  -e ANSIBLE_HOST_KEY_CHECKING=False \
  -v $PWD:/ansible \
  -w /ansible \
  ansible-boto ${@-./run-ansible.sh}

