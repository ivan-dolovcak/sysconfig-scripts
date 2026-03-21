#!/bin/sh
set -eu

. ./lib/common.sh

fileToTrack="$(realpath "$1")"
fileToTrackLocal="$REPO_PATH$fileToTrack"

# Auto-create branch for host if it doesn't exist.
if ! git -C "$REPO_PATH" checkout -b "$BRANCH" 2>/dev/null; then
    git -C "$REPO_PATH" checkout "$BRANCH" 2>/dev/null
fi

# Copy the file and its complete directory structure (mirror).
mkdir -p "$(dirname "$fileToTrackLocal")"
cp "$fileToTrack" "$fileToTrackLocal"

# Prepare the manifest file.
[ -e "$MANIFEST_PATH" ] || touch "$MANIFEST_PATH"
cp "$MANIFEST_PATH" "$MANIFEST_PATH.copy"

pathPart="$fileToTrackLocal"
while :; do
    [ "$pathPart" != "$REPO_PATH" ] || break
    
    # Update manifest (owners and permissions).
    realPathPart=${pathPart#"$REPO_PATH"}
    awk -F '\t' -v path="$realPathPart" '$5 != path' "$MANIFEST_PATH.copy" \
        > "$MANIFEST_PATH.tmp"
    get_stat "$pathPart" >> "$MANIFEST_PATH.tmp"
    mv "$MANIFEST_PATH.tmp" "$MANIFEST_PATH.copy"

    # Normalize permissions for the mirrored file.
    chmod u=rwX,g=rX,o=rX "$pathPart"
    chown "$TARGET_USER:$TARGET_USER" "$pathPart"
    
    pathPart="$(dirname "$pathPart")"
done
mv "$MANIFEST_PATH.copy" "$MANIFEST_PATH"

git -C "$REPO_PATH" add -f -- "$fileToTrackLocal"
echo "Staged $fileToTrack."

. ./lib/check_modified.sh