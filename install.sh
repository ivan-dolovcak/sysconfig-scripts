#!/bin/sh
set -e

start_time=$(date +%s%N)

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$(realpath "$0")")" && pwd)
. "$SCRIPT_DIR/lib/common.sh"

require_root

INSTALL_PATH=/opt/syscfg
BIN_PATH=/usr/local/bin

log_info "Installing to $INSTALL_PATH..."

rm -rfv "$INSTALL_PATH"
mkdir -pv "$INSTALL_PATH"
cp -rv "$SCRIPT_DIR/bin" "$SCRIPT_DIR/lib" "$INSTALL_PATH"

log_info "Linking executables..."
for script in "$INSTALL_PATH/bin"/*; do
    name=$(basename "$script")
    name="syscfg-${name%.*}"
    target=$(realpath "$script")
    link=$BIN_PATH/$name

    rm -f "$link"
    ln -sfv "$target" "$link"
done

end_time=$(date +%s%N)

elapsed_ns=$((end_time - start_time))
elapsed_ms=$((elapsed_ns / 1000000))

log_done "Installation completed in $elapsed_ms ms."