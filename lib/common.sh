#!/bin/sh

export TARGET_USER="ivek"
export BRANCH="$(cat /etc/hostname)"
export REPO_PATH="/home/$TARGET_USER/sysconfig"
export MANIFEST_PATH="$REPO_PATH/manifest"

get_stat()
{
    mode=$( stat -c '%a' -- "$1")
    uid=$(stat -c '%u' -- "$1")
    gid=$(stat -c '%g' -- "$1")
    if [ -d "$1" ]; then
        type=d
    else    
        type=f
    fi

    printf '%s\t%s\t%s\t%s\t%s\n' "$type" "$mode" "$uid" "$gid" "$1"
}