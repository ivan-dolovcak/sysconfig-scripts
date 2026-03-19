#!/bin/sh
# this script generates the manifest file from the already existing mirrored files and directories in local git repo
set -eu

. ./lib/common.sh

find "$REPO_PATH" \( -name .git -o -name .gitignore -o -name manifest \) -prune -o -print |
while IFS= read -r pathPart; do
    get_stat "$pathPart" >> "$REPO_PATH/manifest"
done