#!/bin/sh
set -eu

. ./lib/common.sh

fileToTrack="$(realpath "$1")"
fileToTrackLocal="$REPO_PATH$fileToTrack"

# auto-create branch for host if it doesn't exist:
if ! git -C "$REPO_PATH" checkout -b "$BRANCH" 2>/dev/null
then
    git -C "$REPO_PATH" checkout "$BRANCH"
fi

# copy the file along with its complete directory structure.
mkdir -p "$(dirname -- "$fileToTrackLocal")"
cp "$fileToTrack" "$fileToTrackLocal"

# fix permissions.
tmp="$fileToTrackLocal"
while [ "$tmp" != "$REPO_PATH" ]; do
    echo "$tmp"
    chmod u=rwX,g=rX,o=rX "$tmp"
    chown "$TARGET_USER:$TARGET_USER" "$tmp"
    
    tmp="$(dirname -- "$tmp")"
done
chown "$TARGET_USER:$TARGET_USER" "$REPO_PATH"

git -C "$REPO_PATH" add -f -- "$fileToTrackLocal"

echo "Staged $fileToTrack"
