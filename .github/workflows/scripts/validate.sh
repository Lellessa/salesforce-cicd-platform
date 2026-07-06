#!/bin/bash

set -euo pipefail

NO_COLOR=1 sf project deploy validate --manifest ./manifest/package.xml --target-org $ORG_ALIAS --test-level $TEST_LEVEL \
    > validation.txt

cat validation.txt
sed -n '/Status:/,$p' validation.txt > "$GITHUB_WORKSPACE/summary.txt"