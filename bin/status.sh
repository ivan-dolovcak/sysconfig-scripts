#!/bin/sh
# Check if tracked files/directories got modified or deleted after
# staging/committing in local mirror.
set -eu
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/../lib/common.sh"

require_unprivileged

find "$REPO_PATH" \( $MANIFEST_IGNORE \) -prune -o \
    \( ! -path "$REPO_PATH" \) -print |
while IFS= read -r pathPart; do
    realPathPart=${pathPart#"$REPO_PATH"}

    if [ ! -e "$realPathPart" ]; then
        echo "Tracked file $realPathPart was deleted or moved."
        continue
    fi

    realStat=$(get_stat "$realPathPart")
    manifestStat=$(\
        awk -F '\t' -v path="$realPathPart" '$5 == path' "$MANIFEST_PATH")
    
    if [ "$realStat" != "$manifestStat" ]; then
        echo "Stats of tracked file $realPathPart were modified."
    fi

    [ ! -f "$pathPart" ] && continue

    if ! cmp -s "$pathPart" "$realPathPart"; then
        echo "Tracked file $realPathPart was modified."
    fi
done