#!/bin/bash

set -euo pipefail

echo "$JWT_KEY" > server.key
chmod 600 server.key

sf org login jwt \
  --client-id $CONSUMER_KEY \
  --jwt-key-file server.key \
  --username $USERNAME \
  --alias $ORG_ALIAS \
  --instance-url $URL