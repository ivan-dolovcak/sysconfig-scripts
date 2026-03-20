#!/bin/sh
# Check if tracked files got modified after staging/committing in local mirror.

find "$REPO_PATH" \( $MANIFEST_IGNORE \) -prune -o -print |
while IFS= read -r pathPart; do
    [ ! -f "$pathPart" ] && continue

    realPathPart=${pathPart#"$REPO_PATH"}

    if ! cmp -s "$pathPart" "$realPathPart"; then
        echo "Tracked file $realPathPart was modified."
    fi
done