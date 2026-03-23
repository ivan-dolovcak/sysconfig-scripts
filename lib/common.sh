#!/bin/sh

BRANCH="$(cat /etc/hostname)"
export BRANCH
export TARGET_USER="ivek"
export REPO_PATH="/home/ivek/sysconfig"
export MANIFEST_PATH="$REPO_PATH/syscfg.manifest"
export MANIFEST_IGNORE='
    -name .git
    -o -name .gitignore
    -o -name syscfg.manifest
    -o -name syscfg.manifest.tmp
'

log()
{
    level=$1
    [ -t 1 ] && color=$2 || color=
    shift 2

    printf '%s\r[ %-7s]%s %s\n' "$color" "$level" "$(printf '\033[0m')" "$*"
}

log_done()
{
    log "DONE" "$(printf '\033[32m') " "$@"
}
log_info()
{
    log "INFO" "$(printf '\033[34m') " "$@"
}
log_status()
{
    log "STATUS" "$(printf '\033[36m') " "$@"
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
confirm()
{
    was_interrupted=0
    trap 'was_interrupted=1' INT

    printf "%s [y/N]: " "$1"

    read -r cho

    trap - INT
    [ $was_interrupted -eq 1 ] && return 1

    case $cho in
        [yY]*) return 0 ;;
        *)     return 1 ;;
    esac
}

require_root()
{
    if [ "$(id -u)" -ne 0 ]; then
        die "This script requires root privileges."
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

normalize_file()
{
    file="$1"
    chmod u=rwX,g=rX,o=rX "$file"
    chown "$TARGET_USER:$TARGET_USER" "$file"
}

upsert_manifest()
{
    path=$1
    realPath="${path#"$REPO_PATH"}"
    touch "$MANIFEST_PATH"

    file_deleted=0
    stat=""
    if [ ! -e $path ] || [ ! -e $realPath ]; then
        file_deleted=1
    else
        stat="$(get_stat "$realPath")"
    fi

    # AWK call is wrapped in if...fi to capture its exit code.
    # Using $? is not enough because of set -e.
    if awk -F '\t' -f "$SCRIPT_DIR/../lib/upsert_manifest.awk" \
        -v path="$realPath" -v stat="$stat" -v file_deleted=$file_deleted \
        "$MANIFEST_PATH" > "$MANIFEST_PATH.tmp"
    then
        awkStatus=0
    else
        awkStatus=$?
    fi

    sort -t $'\t' -k5,5 "$MANIFEST_PATH.tmp" -o "$MANIFEST_PATH.tmp"

    mv "$MANIFEST_PATH.tmp" "$MANIFEST_PATH"
    normalize_file "$MANIFEST_PATH"

    case "$awkStatus" in
    1)
        log_info "Inserted manifest line for $realPath."
        ;;
    2)
        log_info "Updated manifest line for $realPath."
        ;;
    3)
        log_info "Deleted manifest line for $realPath."
    esac
}