#!/bin/bash -eux

set -a

AMI_ID=$(< "${AMI_ID_FILE}")

#curl -s "${CFT-https://raw.githubusercontent.com/cyberark/conjur/master/aws/cloudformation/conjur.yml}" | \
#  awk '/.*/; /AWS::EC2::Image::Id/ {printf("    Default: %s\n", AMI_ID)}'  AMI_ID=$AMI_ID > conjur.yml


./ansible.sh ${@-ansible-playbook -vv -e publish-cft.yml}
