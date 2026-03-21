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
    realPath=${1#"$REPO_PATH"}
    mode=$(stat -c '%a' -- "$realPath")
    uid=$(stat -c '%u' -- "$realPath")
    gid=$(stat -c '%g' -- "$realPath")
    if [ -d "$realPath" ]; then
        type=d
    else    
        type=f
    fi

    printf '%s\t%s\t%s\t%s\t%s\n' "$type" "$mode" "$uid" "$gid" "$realPath"
}

# Generate the manifest file from the already existing mirrored files and
# directories in local git repository.
generate_manifest()
{
    touch "$MANIFEST_PATH"
    :> "$MANIFEST_PATH.unstaged"

    find "$REPO_PATH" \( $MANIFEST_IGNORE \) -prune -o \
        \( ! -path "$REPO_PATH" \) -print |
    while IFS= read -r pathPart; do
        if [ -e "${pathPart#"$REPO_PATH"}" ]; then
            get_stat "$pathPart" >> "$MANIFEST_PATH.unstaged"
        fi
    done
}