#!/bin/sh
# checks if tracked files got modified after staging/committing

find "$REPO_PATH" \( -name .git -o -name .gitignore -o -name manifest \) \
    -prune -o ! -path "$REPO_PATH" -print |
while IFS= read -r pathPart; do
    [ ! -f "$pathPart" ] && continue

    realPathPart=${pathPart#"$REPO_PATH"}

    if ! cmp -s "$pathPart" "$realPathPart"; then
        echo "Tracked file $realPathPart was modified."
    fi
done