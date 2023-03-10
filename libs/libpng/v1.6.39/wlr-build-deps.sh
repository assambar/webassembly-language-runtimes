#!/usr/bin/env bash

if [ "${BASH_SOURCE-}" = "$0" ]; then
    echo "You must source this script to add to CFLAGS and LDFLAGS: \$ source $0" >&2
    return
fi

source ${WLR_REPO_ROOT}/scripts/build-helpers/wlr_dependencies.sh

wlr_dependencies_add "zlib" "libs/zlib/v1.2.13" "lib/wasm32-wasi/libz.a" \
    "https://github.com/assambar/webassembly-language-runtimes/releases/download/libs%2Fzlib%2F1.2.13%2B20230306-764c74d/libz-1.2.13-wasi-sdk-19.0.tar.gz"

