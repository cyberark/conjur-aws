#!/bin/bash -eux

set -a

name=conjur

CONJUR_VERSION=0.1.0-stable
CONJUR_IMAGE=quay.io/conjur/${name}:${CONJUR_VERSION}
CONJUR_TARBALL=${name}_${CONJUR_VERSION}.tar.gz

finish() {
  if [ -f "${INSTANCE_ID_FILE}" ]; then
    ./ansible.sh ${@-ansible-playbook -v -e instance_id="$(< ${INSTANCE_ID_FILE})" -e instance_state=absent instance.yml}
  fi
}
trap finish EXIT

./ansible.sh ${@-ansible-playbook -v -e ami_id_filename="${AMI_ID_FILE}" -e instance_id_filename="${INSTANCE_ID_FILE}" build.yml}
