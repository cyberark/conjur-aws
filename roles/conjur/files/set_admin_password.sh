#!/bin/sh -e

api_key="$1"; shift
password="$1"; shift

set -a
. /etc/default/conjur

docker run --rm --net=host \
  -e CONJUR_APPLIANCE_URL=http://localhost \
  -e CONJUR_ACCOUNT \
  -e CONJUR_AUTHN_LOGIN=admin \
  -e CONJUR_AUTHN_API_KEY="$api_key" \
  conjurinc/cli5 user update_password -p "$password"


