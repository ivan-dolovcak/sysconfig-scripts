#!/bin/sh
# Removes the mirror and stages the deletion. upsert_manifest also removes the
# mirror's entry in the manifest.
set -eu
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/../lib/common.sh"

require_root

fileToUntrack="$(realpath "$1")"
fileToUntrackLocal="$REPO_PATH$fileToUntrack"

if [ -e $fileToUntrack ] && [ ! -e $fileToUntrackLocal ]; then
    die "File $fileToUntrack is not tracked."
else
    if [ ! -e $fileToUntrackLocal ]; then
        die "File $fileToUntrack not found."
    else
        log_info "Committing deletion of $fileToUntrack."
    fi
fi

su - $TARGET_USER -s /bin/sh -c \
    "git -C "$REPO_PATH" rm -f -- "$fileToUntrackLocal" >/dev/null 2>&1"
upsert_manifest "$fileToUntrackLocal"

# Delete empty parents from manifest.
parent=$(dirname "$fileToUntrackLocal")
while :; do
    [ "$parent" != "$REPO_PATH" ] || break
    
    upsert_manifest $parent
    
    parent="$(dirname "$parent")"
done

log_done "Untracked $fileToUntrack."