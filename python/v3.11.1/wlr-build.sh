#!/usr/bin/env bash

if [[ ! -v WLR_ENV ]]
then
    echo "WLR build environment is not set"
    exit 1
fi

cd "${WLR_SOURCE_PATH}"

if [[ "${WLR_BUILD_FLAVOR}" == *"aio"* ]]
then
    source ${WLR_REPO_ROOT}/scripts/build-helpers/wlr_wasi_vfs.sh
    wlr_wasi_vfs_setup_dependencies || exit 1
fi

source ${WLR_REPO_ROOT}/scripts/build-helpers/wlr_pkg_config.sh

export CFLAGS_CONFIG="-O0"


# This fails with upgraded clang for wasi-sdk19 and later. Disabled on cpython main.
#
# PyModule_AddIntMacro(module, CLOCK_MONOTONIC) and the like cause this.
# In all POSIX variants CLOCK_MONOTONIC is a numeric constant, so python imports it as int macro
# However, in wasi-libc clockid_t is defined as a pointer to struct __clockid.

export CFLAGS_CONFIG="${CFLAGS_CONFIG} -Wno-int-conversion"

export CFLAGS="${CFLAGS_CONFIG} ${CFLAGS_DEPENDENCIES} ${CFLAGS}"
export LDFLAGS="${LDFLAGS_DEPENDENCIES} ${LDFLAGS}"

export PYTHON_WASM_CONFIGURE="--with-build-python=python3"

if [[ "${WLR_BUILD_FLAVOR}" == *"wasmedge"* ]]
then
    if [[ ! -v WABT_ROOT ]]
    then
        echo "WABT_ROOT is needed to patch imports for wasmedge"
        exit 1
    fi
fi

# By exporting WLR_SKIP_WASM_OPT envvar during the build, the
# wasm-opt wrapper in the wasm-base image will be a dummy wrapper that
# is effectively a NOP.
#
# This is due to https://github.com/llvm/llvm-project/issues/55781, so
# that we get to choose which optimization passes are executed after
# the artifacts have been built.
export WLR_SKIP_WASM_OPT=1

if [[ -z "$WLR_SKIP_CONFIGURE" ]]; then
    logStatus "Configuring build with '${PYTHON_WASM_CONFIGURE}'... "
    CONFIG_SITE=./Tools/wasm/config.site-wasm32-wasi ./configure -C --host=wasm32-wasi --build=$(./config.guess) ${PYTHON_WASM_CONFIGURE} || exit 1
else
    logStatus "Skipping configure..."
fi

export MAKE_TARGETS='python.wasm wasm_stdlib'

logStatus "Building '${MAKE_TARGETS}'... "
make -j ${MAKE_TARGETS} || exit 1

unset WLR_SKIP_WASM_OPT

if [[ "${WLR_BUILD_FLAVOR}" == *"aio"* ]]
then
    logStatus "Packing with wasi-vfs"
    wlr_wasi_vfs_cli pack python.wasm --mapdir /usr::$PWD/usr -o python.wasm || exit 1
fi

logStatus "Optimizing python binary..."
wasm-opt -O2 -o python-optimized.wasm python.wasm || exit 1

if [[ "${WLR_BUILD_FLAVOR}" == *"wasmedge"* ]]
then
    logStatus "Patching python binary for wasmedge..."
    ${WLR_REPO_ROOT}/scripts/build-helpers/patch_wasmedge_wat_sock_accept.sh python-optimized.wasm || exit 1
fi

logStatus "Preparing artifacts... "
TARGET_PYTHON_BINARY=${WLR_OUTPUT}/bin/python.wasm

mkdir -p ${WLR_OUTPUT}/bin 2>/dev/null || exit 1

if [[ "${WLR_BUILD_FLAVOR}" == *"aio"* ]]
then
    cp -v python-optimized.wasm ${TARGET_PYTHON_BINARY} || exit 1
else
    mkdir -p ${WLR_OUTPUT}/usr 2>/dev/null || exit 1
    cp -v python-optimized.wasm ${TARGET_PYTHON_BINARY} || exit 1
    cp -TRv usr ${WLR_OUTPUT}/usr || exit 1
fi

if [[ "${WLR_BUILD_FLAVOR}" != *"aio"* && "${WLR_BUILD_FLAVOR}" != *"wasmedge"* ]]
then

    logStatus "Install includes..."
    make inclinstall \
        prefix=${WLR_OUTPUT} \
        libdir=${WLR_OUTPUT}/lib/wasm32-wasi \
        pkgconfigdir=${WLR_OUTPUT}/lib/wasm32-wasi/pkgconfig || exit 1

    logStatus "Create libpython3.11-aio.a"
(${AR} -M <<EOF
create libpython3.11-aio.a
addlib libpython3.11.a
addlib ${WLR_DEPS_ROOT}/build-output/lib/wasm32-wasi/libz.a
addlib ${WLR_DEPS_ROOT}/build-output/lib/wasm32-wasi/libsqlite3.a
addlib ${WLR_DEPS_ROOT}/build-output/lib/wasm32-wasi/libuuid.a
addlib Modules/expat/libexpat.a
addlib Modules/_decimal/libmpdec/libmpdec.a
save
end
EOF
) || echo exit 1

    mkdir -p ${WLR_OUTPUT}/lib/wasm32-wasi/ 2>/dev/null || exit 1
    cp -v libpython3.11-aio.a ${WLR_OUTPUT}/lib/wasm32-wasi/libpython3.11.a || exit 1

    logStatus "Generating pkg-config file for libpython3.11.a"
    DESCRIPTION="libpython3.11 allows embedding the CPython interpreter"
    STACK_LINKER_FLAGS="-Wl,-z,stack-size=524288 -Wl,--stack-first -Wl,--initial-memory=10485760"

    wlr_pkg_config_create_pc_file "libpython3.11" "${WLR_PACKAGE_VERSION}" "${DESCRIPTION}" "${STACK_LINKER_FLAGS}" || exit 1

    wlr_package_lib || exit 1
fi

logStatus "DONE. Artifacts in ${WLR_OUTPUT}"
