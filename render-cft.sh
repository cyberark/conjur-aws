#!/bin/bash -eux

# Render newly created AMI into CloudFormation template, for testing

./ansible.sh ansible-playbook -v render-cft.yml
