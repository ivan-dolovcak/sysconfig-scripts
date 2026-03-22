#!/bin/sh

BRANCH="$(cat /etc/hostname)"
export BRANCH
export REPO_PATH="/home/ivek/sysconfig"
export MANIFEST_PATH="$REPO_PATH/manifest"
export MANIFEST_IGNORE='
    -name .git
    -o -name .gitignore
    -o -name manifest
    -o -name manifest.unstaged
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

walk_repo()
{
    find "$REPO_PATH" \( $MANIFEST_IGNORE \) -prune -o \
        \( ! -path "$REPO_PATH" \) -print
}

upsert_manifest()
{
    path=$1
    touch "$MANIFEST_PATH"

    realPath="${path#"$REPO_PATH"}"
    stat="$(get_stat "$realPath")"

    awk -F '\t' -v path="$realPath" -v stat="$stat" '
        BEGIN { found=0 }
        $5 == path {
            print stat
            found=1
            next
        }
        { print }
        END {
            if (!found)
                print stat
        }
    ' "$MANIFEST_PATH" > "$MANIFEST_PATH.tmp"

    sort -t $'\t' -k5,5 "$MANIFEST_PATH.tmp" -o "$MANIFEST_PATH.tmp"

    mv "$MANIFEST_PATH.tmp" "$MANIFEST_PATH"
}