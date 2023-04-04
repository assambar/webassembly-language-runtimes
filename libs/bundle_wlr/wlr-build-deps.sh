#!/usr/bin/env bash

if [ "${BASH_SOURCE-}" = "$0" ]; then
    echo "You must source this script to add to CFLAGS and LDFLAGS: \$ source $0" >&2
    return
fi

source ${WLR_REPO_ROOT}/scripts/build-helpers/wlr_dependencies.sh

wlr_dependencies_add "zlib" "libs/zlib/v1.2.13" "lib/wasm32-wasi/libz.a" \
    "https://github.com/vmware-labs/webassembly-language-runtimes/releases/download/libs%2Fzlib%2F1.2.13%2B20230310-c46e363/libz-1.2.13-wasi-sdk-19.0.tar.gz"

wlr_dependencies_add "libpng" "libs/libpng/v1.6.39" "lib/wasm32-wasi/libpng16.a" \
    "https://github.com/vmware-labs/webassembly-language-runtimes/releases/download/libs%2Flibpng%2F1.6.39%2B20230310-13a5f2e/libpng-1.6.39-wasi-sdk-19.0.tar.gz"

wlr_dependencies_add "libjpeg" "libs/libjpeg/v2.1.5.1" "lib/wasm32-wasi/libjpeg.a" \
    "https://github.com/vmware-labs/webassembly-language-runtimes/releases/download/libs%2Flibjpeg%2F2.1.5.1%2B20230310-c46e363/libjpeg-2.1.5.1-wasi-sdk-19.0.tar.gz"

wlr_dependencies_add "libxml2" "libs/libxml2/v2.10.3" "lib/wasm32-wasi/libxml2.a" \
    "https://github.com/vmware-labs/webassembly-language-runtimes/releases/download/libs%2Flibxml2%2F2.10.3%2B20230310-c46e363/libxml2-2.10.3-wasi-sdk-19.0.tar.gz"

wlr_dependencies_add "oniguruma" "libs/oniguruma/v6.9.8" "lib/wasm32-wasi/libonig.a" \
    "https://github.com/vmware-labs/webassembly-language-runtimes/releases/download/libs%2Foniguruma%2F6.9.8%2B20230310-c46e363/libonig-6.9.8-wasi-sdk-19.0.tar.gz"

wlr_dependencies_add "SQLite" "libs/sqlite/version-3.41.2" "lib/wasm32-wasi/libsqlite3.a" \
    "https://github.com/vmware-labs/webassembly-language-runtimes/releases/download/libs%2Fsqlite%2F3.41.2%2B20230329-43f9aea/libsqlite-3.41.2-wasi-sdk-19.0.tar.gz"

wlr_dependencies_add "uuid" "libs/uuid/libuuid-1.0.3" "lib/wasm32-wasi/libuuid.a" \
    "https://github.com/vmware-labs/webassembly-language-runtimes/releases/download/libs%2Flibuuid%2F1.0.3%2B20230310-c46e363/libuuid-1.0.3-wasi-sdk-19.0.tar.gz"
