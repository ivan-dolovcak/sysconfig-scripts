#!/usr/bin/sh

set -euo pipefail

repo="$HOME/sysconfig"
fileToTrack="$(realpath "$1")"
branch="$(cat /etc/hostname)"

# auto-create branch for host if it doesn't exist:
git -C $repo checkout -b $branch 2>/dev/null || git -C $repo checkout $branch

cp --parents $fileToTrack $repo
git -C $repo add -f -- "./$fileToTrack"

echo "Staged $fileToTrack"