#!/bin/sh
set -eu

. ./lib/common.sh

fileToTrack="$(realpath "$1")"
fileToTrackLocal="$REPO_PATH$fileToTrack"

# auto-create branch for host if it doesn't exist:
if ! git -C "$REPO_PATH" checkout -b "$BRANCH" 2>/dev/null; then
    git -C "$REPO_PATH" checkout "$BRANCH" 2>/dev/null
fi

# copy the file along with its complete directory structure.
mkdir -p "$(dirname "$fileToTrackLocal")"
cp "$fileToTrack" "$fileToTrackLocal"

[ -e "$MANIFEST_PATH" ] || touch "$MANIFEST_PATH"
cp "$MANIFEST_PATH" "$MANIFEST_PATH.copy"

pathPart="$fileToTrackLocal"

while :; do
    # update manifest (owners and permissions)
    awk -F '\t' -v path="$pathPart" '$5 != path' "$MANIFEST_PATH.copy" > "$MANIFEST_PATH.tmp"
    get_stat "$pathPart" >> "$MANIFEST_PATH.tmp"
    mv "$MANIFEST_PATH.tmp" "$MANIFEST_PATH.copy"

    # fix permissions.
    chmod u=rwX,g=rX,o=rX "$pathPart"
    chown "$TARGET_USER:$TARGET_USER" "$pathPart"
    
    [ "$pathPart" != "$REPO_PATH" ] || break
    pathPart="$(dirname "$pathPart")"
done
mv "$MANIFEST_PATH.copy" "$MANIFEST_PATH"

git -C "$REPO_PATH" add -f -- "$fileToTrackLocal"

echo "Staged $fileToTrack"

. ./check-modified.sh