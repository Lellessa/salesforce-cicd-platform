#!/bin/bash

set -euo pipefail
source ./.github/workflows/scripts/utils/common.sh

sf project deploy start --manifest ./manifest/package.xml --target-org $ORG_ALIAS --test-level $TEST_LEVEL