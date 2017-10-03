#!/bin/bash -eux

CONJUR_VERSION="${1:-latest}"

./ansible.sh ansible-playbook -v -e conjur_version="$CONJUR_VERSION" publish-cft.yml
