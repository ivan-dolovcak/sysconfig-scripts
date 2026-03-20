#!/bin/sh
# Generate the manifest file from the already existing mirrored files and
# directories in local git repository.

set -eu

. ./lib/common.sh

if [ -e "$MANIFEST_PATH" ]; then
    echo "error: the manifest file already exists."
    exit 1
fi

find "$REPO_PATH" \( $MANIFEST_IGNORE \) -prune -o \
    \( ! -path "$REPO_PATH" \) -print |
while IFS= read -r pathPart; do
    get_stat "$pathPart" >> "$MANIFEST_PATH"
done