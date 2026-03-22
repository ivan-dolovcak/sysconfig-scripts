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
    echo "error: file $fileToUntrack is not tracked."
    exit 1
else
    if [ ! -e $fileToUntrackLocal ]; then
        echo "error: file $fileToUntrack not found."
        exit 1
    else
        echo "info: committing deletion of $fileToUntrack."
    fi
fi

git -C "$REPO_PATH" rm -f -- "$fileToUntrackLocal" >/dev/null 2>&1
upsert_manifest "$fileToUntrackLocal"

echo "Untracked $fileToUntrack."