#!/bin/sh

BRANCH="$(cat /etc/hostname)"
export BRANCH
export REPO_PATH="/home/ivek/sysconfig"
export MANIFEST_PATH="$REPO_PATH/manifest"
export MANIFEST_IGNORE='
    -name .git
    -o -name .gitignore
    -o -name manifest
'

require_unprivileged()
{
    if [ "$(id -u)" -eq 0 ]; then
        echo "error: this script is not intended to be ran as root"
        exit 1
    fi
}

get_stat()
{
    mode=$(stat -c '%a' -- "$1")
    uid=$(stat -c '%u' -- "$1")
    gid=$(stat -c '%g' -- "$1")
    if [ -d "$1" ]; then
        type=d
    else    
        type=f
    fi

    printf '%s\t%s\t%s\t%s\t%s\n' "$type" "$mode" "$uid" "$gid" "$1"
}

upsert_manifest()
{
    path=$1
    realPath="${path#"$REPO_PATH"}"
    touch "$MANIFEST_PATH"

    deleted=0
    stat=""
    if [ ! -e $path ] || [ ! -e $realPath ]; then
        deleted=1
    else
        stat="$(get_stat "$realPath")"
    fi

    awk -F '\t' -v path="$realPath" -v stat="$stat" -v deleted=$deleted '
        BEGIN { found=0 }
        $5 == path {
            if (!deleted)
                print stat
            found=1
            next
        }
        { print }
        END {
            if (!found && !deleted)
                print stat
        }
    ' "$MANIFEST_PATH" > "$MANIFEST_PATH.tmp"

    sort -t $'\t' -k5,5 "$MANIFEST_PATH.tmp" -o "$MANIFEST_PATH.tmp"

    mv "$MANIFEST_PATH.tmp" "$MANIFEST_PATH"
}