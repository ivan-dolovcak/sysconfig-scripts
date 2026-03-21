#!/bin/sh
# Check if tracked files got modified or deleted after staging/committing in
# local mirror.

find "$REPO_PATH" \( $MANIFEST_IGNORE \) -prune -o -print |
while IFS= read -r pathPart; do
    [ ! -f "$pathPart" ] && continue

    realPathPart=${pathPart#"$REPO_PATH"}

    if [ ! -e "$realPathPart" ]; then
        echo "Tracked file $realPathPart was deleted or moved."
        continue
    fi

    if ! cmp -s "$pathPart" "$realPathPart"; then
        echo "Tracked file $realPathPart was modified."
    fi

    realStat=$(get_stat "$realPathPart")
    manifestStat=$(\
        awk -F '\t' -v path="$realPathPart" '$5 == path' "$MANIFEST_PATH")

    if [ -z "$manifestStat" ]; then
        echo "New file: $realPathPart";
        continue
    fi
    
    if [ "$realStat" != "$manifestStat" ]; then
        echo "Stats of tracked file $realPathPart were modified."
    fi
done