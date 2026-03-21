#!/bin/sh
set -eu
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/../lib/common.sh"

fileToTrack="$(realpath "$1")"
fileToTrackLocal="$REPO_PATH$fileToTrack"

# Auto-create branch for host if it doesn't exist.
if ! git -C "$REPO_PATH" checkout -b "$BRANCH" >/dev/null 2>&1; then
    git -C "$REPO_PATH" checkout "$BRANCH" >/dev/null 2>&1
fi

# Copy the file and its complete directory structure (mirror).
mkdir -p "$(dirname "$fileToTrackLocal")"
cp "$fileToTrack" "$fileToTrackLocal"

pathPart="$fileToTrackLocal"
while :; do
    [ "$pathPart" != "$REPO_PATH" ] || break

    # Normalize permissions for the mirrored file.
    chmod u=rwX,g=rX,o=rX "$pathPart"
    chown "$TARGET_USER:$TARGET_USER" "$pathPart"
    
    pathPart="$(dirname "$pathPart")"
done

# Regenerate manifest (owners and permissions).
generate_manifest

git -C "$REPO_PATH" add -f -- "$fileToTrackLocal" >/dev/null 2>&1
git -C "$REPO_PATH" add -f -- "$MANIFEST_PATH" >/dev/null 2>&1
echo "Staged $fileToTrack."

. "$SCRIPT_DIR/../lib/check_modified.sh"