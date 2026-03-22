#!/bin/sh

export TARGET_USER="ivek"
BRANCH="$(cat /etc/hostname)"
export BRANCH
export REPO_PATH="/home/$TARGET_USER/sysconfig"
export MANIFEST_PATH="$REPO_PATH/manifest"
export MANIFEST_IGNORE='
    -name .git
    -o -name .gitignore
    -o -name manifest
    -o -name manifest.unstaged
'

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

# Generate the manifest file from the already existing mirrored files and
# directories in local git repository.
generate_manifest()
{
    touch "$MANIFEST_PATH"
    :> "$MANIFEST_PATH.unstaged"

    walk_repo | while IFS= read -r pathPart; do
        realPathPart="${pathPart#"$REPO_PATH"}"
        if [ -e $realPathPart ]; then
            get_stat "$realPathPart" >> "$MANIFEST_PATH.unstaged"
        fi
    done
}