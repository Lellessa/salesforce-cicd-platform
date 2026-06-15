#!/bin/bash

set -euo pipefail
source utils/common.sh

ORG_ALIAS=${1:?Usage: deploy.sh <dev|it|qa|prod>}

goto_project

sf project deploy start --manifest ./manifest/package.xml --target-org $ORG_ALIAS