#!/usr/bin/env bash

if [ "${BASH_SOURCE-}" = "$0" ]; then
    echo "You must source this script: \$ source $0" >&2
    return
fi

function wl-env-unset() {
    if [[ ! -v WASMLABS_ENV ]]
    then
        echo "Nothing to unset"
        return
    fi

    source ${WASMLABS_ENV}/../wl-env-repo.sh --unset
    unset WASMLABS_SOURCE_PATH
    unset WASMLABS_TAG

    unset WASMLABS_MAKE
    unset WASMLABS_ENV_NAME
    unset WASMLABS_STAGING
    unset WASMLABS_OUTPUT_BASE
    unset WASMLABS_OUTPUT
    unset WASMLABS_REPO_ROOT

    if [[ -v WASMLABS_OLD_PS1 ]]
    then
        export PS1="${WASMLABS_OLD_PS1}"
        unset WASMLABS_OLD_PS1
    fi

    unset -f wl-env-unset
    unset WASMLABS_ENV

    if (env | grep WASMLABS_ -q)
    then
        echo "Leaked env variables were not cleared:"
        env | grep WASMLABS_
    fi

    return
}
export -f wl-env-unset


# Expect path to root folder for build environment
PATH_TO_ENV="$( cd "$1" && pwd )"

if [[ ! -d ${PATH_TO_ENV} || ! -f ${PATH_TO_ENV}/wl-build.sh ]]
then
    echo "Bad environment location: '${PATH_TO_ENV}'"
    return
fi

# Noop if environment is already set
if [[ -v WASMLABS_ENV ]]
then
    echo "Environment is already set"
    return
fi

export WASMLABS_REPO_ROOT="$(git rev-parse --show-toplevel)"
export WASMLABS_MAKE=${WASMLABS_REPO_ROOT}/wl-make.sh

if [ "${WASMLABS_BUILD_TYPE}" = "dependency" ]
then
    export WASMLABS_STAGING_ROOT=${WASMLABS_DEPS_ROOT}/build-staging
else
    export WASMLABS_STAGING_ROOT=${WASMLABS_REPO_ROOT}/build-staging
fi

if [[ -f ${PATH_TO_ENV}/wl-env-repo.sh ]]
then
    # Setup source and staging for targets from another repository
    source ${PATH_TO_ENV}/wl-env-repo.sh

    export WASMLABS_TAG=$(basename ${PATH_TO_ENV})

    export WASMLABS_ENV_NAME="${WASMLABS_REPO_NAME}/${WASMLABS_TAG}"
    export WASMLABS_STAGING=${WASMLABS_STAGING_ROOT}/${WASMLABS_ENV_NAME}${WASMLABS_BUILD_FLAVOR:+-$WASMLABS_BUILD_FLAVOR}
    export WASMLABS_SOURCE_PATH=${WASMLABS_STAGING}/checkout

elif [[ -f ${PATH_TO_ENV}/wl-env-local.sh ]]
then
    source ${PATH_TO_ENV}/wl-env-local.sh

    if [[ ! -v WASMLABS_ENV_NAME ]]
    then
        echo "wl-env-local.sh must set WASMLABS_ENV_NAME"
        exit 1
    fi

    # Setup source and staging for targets in this repository
    export WASMLABS_STAGING=${WASMLABS_STAGING_ROOT}/${WASMLABS_ENV_NAME}${WASMLABS_BUILD_FLAVOR:+-$WASMLABS_BUILD_FLAVOR}
    export WASMLABS_SOURCE_PATH=${WASMLABS_ENV_NAME}
else
    echo "Provide either wl-env-repo.sh or wl-env-local.sh scripts to build this target - '${PATH_TO_ENV}'"
    exit 1
fi

if [[ ! -v WASMLABS_OUTPUT ]]
then
    echo "Current output is ${WASMLABS_OUTPUT}."
    export WASMLABS_OUTPUT_BASE=${WASMLABS_REPO_ROOT}/build-output
    export WASMLABS_OUTPUT=${WASMLABS_OUTPUT_BASE}/${WASMLABS_ENV_NAME}${WASMLABS_BUILD_FLAVOR:+-$WASMLABS_BUILD_FLAVOR}
fi
echo "Using output ${WASMLABS_OUTPUT}."


if [ "${WASMLABS_BUILD_TYPE}" = "dependency" ]
then
    export WASMLABS_OUTPUT=${WASMLABS_DEPS_ROOT}/build-output
    echo "Building ${WASMLABS_ENV_NAME} as a dependency"
else
    export WASMLABS_DEPS_ROOT=${WASMLABS_STAGING}/deps
fi

export WASMLABS_OLD_PS1="${PS1-}"
export PS1="(${WASMLABS_ENV_NAME}) ${PS1-}"

mkdir -p ${WASMLABS_STAGING}
mkdir -p ${WASMLABS_OUTPUT}
mkdir -p ${WASMLABS_DEPS_ROOT}

export WASMLABS_ENV=${PATH_TO_ENV}

if [[ -f ${WASMLABS_REPO_ROOT}/.wl-local-conf.sh && ! -v WASI_SDK_PATH && ! -v BINARYEN_PATH && ! -v WABT_ROOT && ! -v WASI_VFS_ROOT ]]
then
    echo "!! Using build tools as configured in '${WASMLABS_REPO_ROOT}/.wl-local-conf.sh'"
    source ${WASMLABS_REPO_ROOT}/.wl-local-conf.sh

elif [[ -f ${HOME}/.wl-local-conf.sh && ! -v WASI_SDK_PATH && ! -v BINARYEN_PATH && ! -v WABT_ROOT && ! -v WASI_VFS_ROOT ]]
then
    echo "!! Using build tools as configured in '${HOME}/.wl-local-conf.sh'"
    source ${HOME}/.wl-local-conf.sh
fi
