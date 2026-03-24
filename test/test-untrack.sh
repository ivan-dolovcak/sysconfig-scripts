#!/bin/sh
# set -eu
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$(realpath "$0")")" && pwd)
. "$SCRIPT_DIR/../lib/common.sh"
. "$SCRIPT_DIR/lib/test_common.sh"

cp "$SCRIPT_DIR/lib/manifest_stable" "$MANIFEST_PATH"

# ------------------------------------------------------------------------------
log_test Create real files for tracking.

mkdir "$SCRIPT_DIR/testing"
chmod 700 "$SCRIPT_DIR/testing"
touch "$SCRIPT_DIR/testing/test2"
touch "$SCRIPT_DIR/testing/test3"
touch "$SCRIPT_DIR/test1"

tree "$SCRIPT_DIR"
status

pause

# ------------------------------------------------------------------------------
log_test Track files, show mirrored files and the manifest.

track "$SCRIPT_DIR/test1"

tree "$REPO_PATH"
cat "$MANIFEST_PATH"
status

pause

# ------------------------------------------------------------------------------
log_test Track a new file

track "$SCRIPT_DIR/testing/test2"
# track /etc/wireguard/wg0.conf

tree "$REPO_PATH"
cat "$MANIFEST_PATH"
status

pause

# ------------------------------------------------------------------------------
log_test Attempt to untrack a non-existing file

untrack "test/testX"

pause

# ------------------------------------------------------------------------------
log_test Attempt to untrack a non-tracked file

untrack "$SCRIPT_DIR/testing/test3"

pause

# ------------------------------------------------------------------------------
log_test Untrack a file

untrack "$SCRIPT_DIR/testing/test2"
# untrack /etc/wireguard/wg0.conf
status

tree "$REPO_PATH"
cat "$MANIFEST_PATH"

pause

# ------------------------------------------------------------------------------
log_test Retrack a file

track "$SCRIPT_DIR/testing/test2"
# track /etc/wireguard/wg0.conf
status

tree "$REPO_PATH"
cat "$MANIFEST_PATH"

pause

# ------------------------------------------------------------------------------
log_test X. Cleanup.

rm -r "$SCRIPT_DIR/testing" "$SCRIPT_DIR/test1"
status
git -C "$REPO_PATH" reset --hard HEAD