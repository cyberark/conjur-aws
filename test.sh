#!/bin/bash -ex

ami_id_filename="$1"; shift

curl -s "${CFT-https://raw.githubusercontent.com/cyberark/conjur/cft_170815/aws/cft.yml}" > conjur-ce.yml

set -a
AMI_ID=$(< "${ami_id_filename}")
: ${STACK_NAME=conjur-ce-test-$(date +%s)}

finish() {
  ./ansible.sh ansible-playbook -e stack_name=${STACK_NAME} -e test_stack=false -vvv test.yml
}
trap finish EXIT
  
./ansible.sh ${@-ansible-playbook -e stack_name=${STACK_NAME} -vvv test.yml}
