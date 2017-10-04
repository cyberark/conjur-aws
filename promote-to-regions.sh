#!/bin/bash -eu

SOURCE_AMI="${1:-$(cat AMI.txt)}"
PROMOTER_IMAGE='registry.tld/conjurinc/ami-promoter'

REGIONS=(
  us-east-2
  us-west-1
  us-west-2
  eu-west-1
  eu-central-1
  ap-southeast-1
  ap-southeast-2
  ap-northeast-1
  ap-northeast-2
  sa-east-1
)

regions_string=$(IFS=, ; echo "${REGIONS[*]}")  # comma-delimited, for ami-promoter

cat <<'EOF' >> vars-amis.json
{
  "us-east-2": "ami-34fcd151",
  "us-west-1": "ami-499cac29",
  "us-west-2": "ami-0bf50f73",
  "eu-west-1": "ami-6a5c8813",
  "eu-central-1": "ami-b72290d8",
  "ap-southeast-1": "ami-fedba79d",
  "ap-southeast-2": "ami-18bd5e7a",
  "ap-northeast-1": "ami-ce4d9ca8",
  "ap-northeast-2": "ami-8707dde9",
  "sa-east-1": "ami-8d6f10e1"
}
EOF

# docker pull $PROMOTER_IMAGE
# summon docker run --rm --env-file @SUMMONENVFILE $PROMOTER_IMAGE \
#   --ami $SOURCE_AMI \
#   --regions "$regions_string" \
#   | tee vars-amis.json
