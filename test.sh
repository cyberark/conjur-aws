#!/bin/bash -ex

curl -s "${CFT-https://raw.githubusercontent.com/cyberark/conjur/cft_170815/aws/cft.yml}" > conjur-ce.yml

set -a
AMI_ID=$(< ami-id.out)
: ${STACK_NAME=conjur-ce-test-$(date +%s)}

./ansible.sh ${@-ansible-playbook -e stack_name=${STACK_NAME} -v test.yml}
