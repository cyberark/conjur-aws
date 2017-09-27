#!/bin/bash -eu

SOURCE_AMI="${1:-$(cat AMI.txt)}"
PROMOTER_IMAGE='registry.tld/conjurinc/ami-promoter'

REGIONS=(
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

docker pull $PROMOTER_IMAGE
summon docker run --rm --env-file @SUMMONENVFILE $PROMOTER_IMAGE \
  --ami $SOURCE_AMI \
  --regions "$regions_string" \
  | tee AMIS.json

# Add the source AMI to the list so it is complete
source_ami_string="{\"us-east-1\": \"$SOURCE_AMI\","
sed "1s/^./$source_ami_string /" AMIS.json
