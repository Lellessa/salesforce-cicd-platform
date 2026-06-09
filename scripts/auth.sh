#/bin/bash

set -euo pipefail

ALIAS=$1

sf org login web \
  --alias "$ALIAS" \
  --set-default