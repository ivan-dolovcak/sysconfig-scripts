#!/bin/sh
# Mirror the file into a local repository (along with its directory tree). Git
# doesn't track the mode and ownership of a file. This metadata is stored
# separately in a manifest file.
set -eu
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/../lib/common.sh"

require_root

fileToTrack="$(realpath "$1")"
fileToTrackLocal="$REPO_PATH$fileToTrack"

[ -e "$fileToTrackLocal" ] && retracking=1 || retracking=0

# Auto-create branch for host if it doesn't exist.
if ! git -C "$REPO_PATH" checkout -b "$BRANCH" >/dev/null 2>&1; then
    git -C "$REPO_PATH" checkout "$BRANCH" >/dev/null 2>&1
fi

# Mirror.
mkdir -p "$(dirname "$fileToTrackLocal")"
cp "$fileToTrack" "$fileToTrackLocal"

pathPart="$fileToTrackLocal"
while :; do
    [ "$pathPart" != "$REPO_PATH" ] || break

    # Normalize permissions for the mirrored file.
    normalize_file $pathPart

    upsert_manifest $pathPart
    
    pathPart="$(dirname "$pathPart")"
done

# Stage changes.
su - $TARGET_USER -s /bin/sh -c \
    "git -C "$REPO_PATH" add -f -- "$fileToTrackLocal""
su - $TARGET_USER -s /bin/sh -c \
    "git -C "$REPO_PATH" add -f -- "$MANIFEST_PATH""

if [ $retracking -eq 1 ]; then
    log_done "Retracking $fileToTrack."
else
    log_done "Tracking $fileToTrack."
fi