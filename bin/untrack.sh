#!/bin/sh
# Removes the mirror and stages the deletion. upsert_manifest also removes the
# mirror's entry in the manifest.
set -eu
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/../lib/common.sh"

require_unprivileged

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

git -C "$REPO_PATH" rm -f -- "$fileToUntrackLocal" >/dev/null 2>&1
upsert_manifest "$fileToUntrackLocal"

log_done "Untracked $fileToUntrack."