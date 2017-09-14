#!/bin/bash -eux

set -a

AMI_ID=$(< "${AMI_ID_FILE}")

./ansible.sh ${@-ansible-playbook -vv fetch-cft.yml}
