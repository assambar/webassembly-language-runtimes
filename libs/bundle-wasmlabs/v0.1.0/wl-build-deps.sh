#!/bin/bash

logStatus "Building dependencies for libpng 1.6.39..."

if [ "${BASH_SOURCE-}" = "$0" ]; then
    echo "You must source this script to add to CFLAGS and LDFLAGS: \$ source $0" >&2
    return
fi

source ${WASMLABS_REPO_ROOT}/scripts/build-helpers/wl_dependencies.sh

wl_dependencies_add "zlib" "libs/zlib/v1.2.13" "lib/wasm32-wasi/libz.a"
wl_dependencies_add "libpng" "libs/libpng/v1.6.39" "lib/wasm32-wasi/libpng16.a"
wl_dependencies_add "libxml2" "libs/libxml2/v2.10.3" "lib/wasm32-wasi/libxml2.a"
wl_dependencies_add "oniguruma" "libs/oniguruma/v6.9.8" "lib/wasm32-wasi/libonig.a"
wl_dependencies_add "SQLite" "libs/sqlite/version-3.39.2" "lib/wasm32-wasi/libsqlite3.a"
