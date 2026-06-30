#!/bin/bash

set -euo pipefail

SOURCE_BRANCH="${{ github.event.workflow_run.head_branch }}"

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

COUNT=$(gh pr list \
    --base "$TARGET_BRANCH" \
    --head "$SOURCE_BRANCH" \
    --state open \
    --json number \
    --jq 'length')

if [ "$COUNT" -gt 0 ]; then
    echo "Promotion PR already exists."
    exit 0
fi

gh pr create \
    --base "$TARGET_BRANCH" \
    --head "$SOURCE_BRANCH" \
    --title "Promote $SOURCE_BRANCH → $TARGET_BRANCH" \
    --body "
    ## Automated Promotion

    Source: \`$SOURCE_BRANCH\`
    Target: \`$TARGET_BRANCH\`

    Generated automatically after successful deployment.
    "