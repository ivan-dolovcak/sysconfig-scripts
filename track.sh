#!/bin/sh
set -eu

repo="$HOME/sysconfig"
fileToTrack="$(realpath "$1")"
branch="$(cat /etc/hostname)"

# auto-create branch for host if it doesn't exist:
if ! git -C "$repo" checkout -b "$branch" 2>/dev/null
then
    git -C "$repo" checkout "$branch"
fi

# copy the file along with its complete directory structure.
cp --parents "$fileToTrack" "$repo"

git -C "$repo" add -f -- "./$fileToTrack"

echo "Staged $fileToTrack"
