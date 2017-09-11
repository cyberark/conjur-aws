#!/bin/bash -eux

set -a

AMI_ID=$(< "${AMI_ID_FILE}")
: ${STACK_NAME=conjur-ce-test-$(date +%s)}

finish() {
  ./ansible.sh ansible-playbook -e stack_name=${STACK_NAME} -e stack_state=absent -vvv stack.yml
}
trap finish EXIT
  
./ansible.sh ${@-ansible-playbook -e stack_name=${STACK_NAME} -vvv test.yml}
