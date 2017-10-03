#!/bin/bash -eux
# Render newly created AMI into CloudFormation template, for testing

CONJUR_VERSION="${1:-latest}"

./ansible.sh ansible-playbook -v -e conjur_version="$CONJUR_VERSION" render-cft.yml
