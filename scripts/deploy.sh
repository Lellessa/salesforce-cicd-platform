#!/bin/bash

set -euo pipefail
source ./scripts/utils/common.sh

goto_project

sf project deploy start --manifest ./manifest/package.xml --target-org $ORG_ALIAS --test-level $TEST_LEVEL