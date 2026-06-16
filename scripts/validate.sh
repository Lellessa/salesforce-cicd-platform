#!/bin/bash

set -euo pipefail
source utils/common.sh

goto_project

sf project deploy validate --manifest ./manifest/package.xml --target-org $ORG_ALIAS