#!/bin/bash -ex

curl -s https://raw.githubusercontent.com/cyberark/conjur/cft_170815/aws/cft.yml > conjur-ce.yml

set -a
AMI_ID=$(< ami-id.out)

# ./ansible.sh ${@-ansible-playbook -v test.yml}
