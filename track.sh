#!/usr/bin/sh

set -euo pipefail

repo="$HOME/sysconfig"
fileToTrack="$(realpath "$1")"
branch="$(cat /etc/hostname)"

echo $fileToTrack
echo $repo
echo $branch

git -C $repo checkout $branch

cp --parents $fileToTrack $repo
git -C $repo add -f -- "./$fileToTrack"