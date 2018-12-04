#!/bin/bash -eu

set -o pipefail

CONJUR_VERSION="${1:-untagged}"
# Default these variables to make development easier. They should be get in the environment (i.e. in the Jenkinsfile)
# when this script gets used as part of a build.
: ${INSTANCE_ID_FILE=dev-EC2.txt}
: ${AMI_ID_FILE=dev-AMI.txt}

finish() {
  if [ -f "${INSTANCE_ID_FILE}" ]; then
    ./ansible.sh ansible-playbook -v \
      -e instance_id="$(< ${INSTANCE_ID_FILE})" \
      -e instance_state=absent \
      instance.yml
  fi
}
trap finish EXIT

mkdir -p vars  # variables passed between plays are stored here

echo "Fetching latest CoreOS AMI..."
export BASE_AMI=$(docker run --rm --env-file ansible.env \
  mesosphere/aws-cli ec2 describe-images --filters '[
    {"Name": "owner-id", "Values": ["595879546273"] },
    {"Name": "name", "Values": ["CoreOS-stable*"] },
    {"Name": "virtualization-type", "Values": ["hvm"] },
    {"Name": "architecture", "Values": ["x86_64"] },
    {"Name": "hypervisor", "Values": ["xen"] },
    {"Name": "root-device-type", "Values": ["ebs"] },
    {"Name": "state", "Values": ["available"] }
    ]' \
    --query 'reverse(sort_by(Images, &CreationDate))[:1].ImageId | [0]' \
    --region $AWS_REGION \
    --output text
  )

echo "CoreOS AMI: $BASE_AMI"

echo "Starting build"

./ansible.sh ansible-playbook -v \
  -e ami_id_filename="${AMI_ID_FILE}" \
  -e instance_id_filename="${INSTANCE_ID_FILE}" \
  -e conjur_version="$CONJUR_VERSION" \
  build-ami.yml
