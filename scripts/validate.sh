#!/bin/bash

set -euo pipefail

goto_project

source utils/common.sh

sf project deploy validate --manifest ./manifest/package.xml --target-org $ORG_ALIAS