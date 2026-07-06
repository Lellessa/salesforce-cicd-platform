#!/bin/bash

set -euo pipefail

sf project deploy start --manifest ./manifest/package.xml --target-org $ORG_ALIAS --test-level $TEST_LEVEL