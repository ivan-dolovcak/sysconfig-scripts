#!/bin/sh
# set -eu
# set -x
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/../lib/common.sh"
. "$SCRIPT_DIR/lib/test_common.sh"

cp "$SCRIPT_DIR/lib/manifest_stable" "$MANIFEST_PATH"

# ------------------------------------------------------------------------------
log_test Create real files for tracking.

mkdir "$SCRIPT_DIR/testing"
touch "$SCRIPT_DIR/testing/test2"
touch "$SCRIPT_DIR/test1"

tree "$SCRIPT_DIR"
cat "$MANIFEST_PATH"
status

pause

# ------------------------------------------------------------------------------
log_test Track files, show mirrored files and the manifest.

track "$SCRIPT_DIR/test1"
# Track a safe system file to check how stats and owners are handled.
track "/etc/hostname"
track "/etc/wireguard/wg0.conf"

tree "$REPO_PATH"
cat "$MANIFEST_PATH"
status

pause

# ------------------------------------------------------------------------------
log_test Track a new file and modify an already tracked file. Modify testing dir stats.

# Write to file and also change its stats.
echo test > "$SCRIPT_DIR/test1"
chmod +x "$SCRIPT_DIR/test1"
track "$SCRIPT_DIR/testing/test2"
chmod 700 "$SCRIPT_DIR/testing"

tree "$REPO_PATH"
cat "$MANIFEST_PATH"
status

pause

# ------------------------------------------------------------------------------
log_test Re-track a file and delete an already tracked file.

rm "$SCRIPT_DIR/testing/test2"
track "$SCRIPT_DIR/test1"

tree "$REPO_PATH"
cat "$MANIFEST_PATH"
status

pause

log_test Track a new file. See if parent dir will update manifest.
touch "$SCRIPT_DIR/testing/test3"
track "$SCRIPT_DIR/testing/test3"

tree "$REPO_PATH"
cat "$MANIFEST_PATH"
status

pause

# ------------------------------------------------------------------------------
log_test Cleanup.

rm -r "$SCRIPT_DIR/testing" "$SCRIPT_DIR/test1"
status
git -C "$REPO_PATH" reset --hard HEAD