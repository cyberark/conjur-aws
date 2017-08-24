#!/bin/bash -ex

name=conjur

set -a
CONJUR_VERSION=0.1.0-stable
CONJUR_IMAGE=quay.io/conjur/${name}:${CONJUR_VERSION}
CONJUR_TARBALL=${name}_${CONJUR_VERSION}.tar.gz

./ansible.sh ${@-ansible-playbook -v build.yml}
