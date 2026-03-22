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

log()
{
    level=$1
    [ -t 1 ] && color=$2 || color=
    shift 2

    printf '%s\r[ %-6s]%s %s\n' "$color" "$level" "$(printf '\033[0m')" "$*"
}

log_done()
{
    log "DONE" "$(printf '\033[32m') " "$@"
}
log_info()
{
    log "INFO" "$(printf '\033[34m') " "$@"
}
log_warn()
{
    log "WARN" "$(printf '\033[33m') " "$@"
}
die()
{
    log "ERROR" "$(printf '\033[31m') " "$@"
    exit 1
}
log_test()
{
    log "TEST" "$(printf '\033[35m') " "$@"
}

require_unprivileged()
{
    [ "$(id -u)" -ne 0 ] || die "This script is not intended to be ran as root."
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