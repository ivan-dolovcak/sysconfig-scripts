#!/bin/sh
# set -eu
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$SCRIPT_DIR/../lib/common.sh"
. "$SCRIPT_DIR/lib/test_common.sh"

log_info "Sample text."
log_warn "Sample text."
log_done "Sample text."
log_test "Sample text."
# die "Sample text."

if confirm "show colors?"; then
    echo "done"
else
    die "aborted"
fi

for i in $(seq 30 37); do
    printf '\033[%smColor\033[0m %s\n' $i $i
    printf '\033[%s;1mColor bright\033[0m %s\n' $i $i
done

for i in $(seq 40 47); do
    printf '\033[%smBackground\033[0m %s\n' $i $i
done