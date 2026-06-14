#/bin/bash

set -euo pipefail

ENVIROMENT=${1:?Usage: auth.sh <dev|it|qa>}

source "../config/enviroments/${ENVIROMENT}.env"

sf org login jwt \
  --client-id $CONSUMER_KEY \
  --jwt-key-file $KEY \
  --username $USERNAME \
  --alias $ORG_ALIAS \
  --instance-url $URL