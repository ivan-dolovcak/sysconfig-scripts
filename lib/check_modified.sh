#!/bin/sh
# Check if tracked files/directories got modified or deleted after
# staging/committing in local mirror.

walk_repo | while IFS= read -r pathPart; do
    realPathPart=${pathPart#"$REPO_PATH"}

    if [ ! -e "$realPathPart" ]; then
        echo "Tracked file $realPathPart was deleted or moved."
        continue
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

    [ ! -f "$pathPart" ] && continue

    if ! cmp -s "$pathPart" "$realPathPart"; then
        echo "Tracked file $realPathPart was modified."
    fi
done