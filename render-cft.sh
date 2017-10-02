#!/bin/bash -eux

# Render newly created AMI into CloudFormation template, for testing

./ansible.sh ansible-playbook -v \
  -e "@vars-amis.yml" \
  render-cft.yml
