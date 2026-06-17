#!/bin/bash

set -euo pipefail
source ./scripts/utils/common.sh

goto_project

sf project deploy validate --manifest ./manifest/package.xml --target-org $ORG_ALIAS --test-level $TEST_LEVEL --json \
    > validation.txt

cat validation.txt
sed -n '/Status:/,$p' validation.txt > "$GITHUB_WORKSPACE/summary.txt"