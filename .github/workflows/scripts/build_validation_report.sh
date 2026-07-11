#!/usr/bin/env bash

set -euo pipefail

REPORT=$1

readarray -t validationInfo < <(
    jq -r '
        .result |
        .status,
        .id,
        .deployUrl,
        .numberComponentsTotal,
        .numberTestsCompleted,
        .numberTestErrors,
        .numberTestsTotal
    ' "$REPORT"
)

cat > validate_report.md <<EOF
# Salesforce Deployment Validation Report

## Deployment Summary

| Field | Value |
|--------|-------|
| **Status** | ${validationInfo[0]} |
| **Deploy ID** | [\`${validationInfo[1]}\`](${validationInfo[2]}) |
| **Number of Components** | \`${validationInfo[3]}\` |

## Test Results

| Metric | Result |
|--------|-------|
| **Passing Tests** | ${validationInfo[4]} |
| **Failing Tests** | ${validationInfo[5]} |
| **Total Tests** | ${validationInfo[6]} |

## Validated Source

| State | Name | Type | Path |
|-------|------|------|------|
EOF

jq -r '.result.files[] | "| \(.state) | `\(.fullName)` | \(.type) | `\(.filePath | sub("^.*force-app/"; "force-app/"))` |"' $REPORT >> validate_report.md