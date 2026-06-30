#!/bin/bash

set -euo pipefail

SOURCE_BRANCH="${{ github.event.workflow_run.head_branch }}"

echo "SOURCE_BRANCH: $SOURCE_BRANCH"

TARGET_BRANCH="default"
case "$SOURCE_BRANCH" in
    dev)
        TARGET_BRANCH="it"
        ;;
    it)
        TARGET_BRANCH="qa"
        ;;
    qa)
        TARGET_BRANCH="prod"
        ;;
    *)
        echo "No promotion path for $SOURCE_BRANCH"
        exit 0
        ;;
esac

echo "TARGET_BRANCH: $TARGET_BRANCH"

COUNT=$(gh pr list \
    --base "$TARGET_BRANCH" \
    --head "$SOURCE_BRANCH" \
    --state open \
    --json number \
    --jq 'length')

echo "COUNT: $COUNT"

#gh pr create \
#    --base "$TARGET_BRANCH" \
#    --head "$SOURCE_BRANCH" \
#    --title "Promote $SOURCE_BRANCH → $TARGET_BRANCH" \
#    --body "
    ## Automated Promotion

#    Source: \`$SOURCE_BRANCH\`
#    Target: \`$TARGET_BRANCH\`

#    Generated automatically after successful deployment.
#    "