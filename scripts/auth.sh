#!/bin/bash

set -euo pipefail

ENVIROMENT=${1:?Usage: auth.sh <dev|it|qa>}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../config/enviroments/${ENVIROMENT}.env"

echo $SECRET

sf org login jwt \
  --client-id $CONSUMER_KEY \
  --jwt-key-file $SECRET \
  --username $USERNAME \
  --alias $ORG_ALIAS \
  --instance-url $URL