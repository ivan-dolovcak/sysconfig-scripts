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

pathPart="$fileToTrackLocal"
while :; do
    [ "$pathPart" != "$REPO_PATH" ] || break

    # Normalize permissions for the mirrored file.
    chmod u=rwX,g=rX,o=rX "$pathPart"
    chown "$TARGET_USER:$TARGET_USER" "$pathPart"
    
    pathPart="$(dirname "$pathPart")"
done

# Regenerate manifest (owners and permissions).

touch "$MANIFEST_PATH"
:> "$MANIFEST_PATH.unstaged"

find "$REPO_PATH" \( $MANIFEST_IGNORE \) -prune -o \
    \( ! -path "$REPO_PATH" \) -print |
while IFS= read -r pathPart; do
    if [ -e "${pathPart#"$REPO_PATH"}" ]; then
        get_stat "$pathPart" >> "$MANIFEST_PATH.unstaged"
    fi
done

git -C "$REPO_PATH" add -f -- "$fileToTrackLocal"
git -C "$REPO_PATH" add -f -- "$MANIFEST_PATH"
echo "Staged $fileToTrack."

. ./lib/check_modified.sh