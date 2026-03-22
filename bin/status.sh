#!/bin/sh
# Check if tracked files/directories got modified or deleted after
# staging/committing in local mirror.
set -eu
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/../lib/common.sh"

require_root

flag_changed="$SCRIPT_DIR/flag_changed.tmp"
rm -f "$flag_changed"

find "$REPO_PATH" \( $MANIFEST_IGNORE \) -prune -o \
    \( ! -path "$REPO_PATH" \) -print |
while IFS= read -r pathPart; do
    realPathPart=${pathPart#"$REPO_PATH"}

    if [ ! -e "$realPathPart" ]; then
        log_status "Tracked file $realPathPart was deleted or moved."
        touch "$flag_changed"
        continue
    fi

    realStat=$(get_stat "$realPathPart")
    manifestStat=$(\
        awk -F '\t' -v path="$realPathPart" '$5 == path' "$MANIFEST_PATH")
    
    if [ "$realStat" != "$manifestStat" ]; then
        touch "$flag_changed"
        log_status "Stats of tracked file $realPathPart were modified."
    fi

    [ ! -f "$pathPart" ] && continue

    if ! cmp -s "$pathPart" "$realPathPart"; then
        touch "$flag_changed"
        log_status "Tracked file $realPathPart was modified."
    fi
done

if [ ! -e $flag_changed ]; then
    log_status "No changes detected - mirrors are the same as real filesystem."
fi
rm -f "$flag_changed"