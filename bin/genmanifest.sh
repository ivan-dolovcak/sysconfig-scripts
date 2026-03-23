#!/bin/sh
# Generate a manifest file from scratch.
set -eu
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$(realpath "$0")")" && pwd)
. "$SCRIPT_DIR/../lib/common.sh"

require_root

find "$REPO_PATH" \( $MANIFEST_IGNORE \) -prune -o \
    \( ! -path "$REPO_PATH" \) -print |
while IFS= read -r path; do
    upsert_manifest "$path"
done