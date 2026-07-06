#!/bin/bash

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../src/salesforce-app" && pwd)"

function goto_project() {
    cd "$PROJECT_DIR"
}