#!/usr/bin/env bash

if [[ $1 == "--unset" ]]
then
    unset WASMLABS_REPO
    unset WASMLABS_REPO_BRANCH
    unset WASMLABS_ENV_NAME
    unset WASMLABS_PACKAGE_VERSION
    unset WASMLABS_PACKAGE_NAME
    return
fi

export WASMLABS_REPO=https://github.com/sqlite/sqlite.git
export WASMLABS_REPO_BRANCH=version-3.39.2
export WASMLABS_ENV_NAME=sqlite/v3.39.2
export WASMLABS_PACKAGE_VERSION=3.39.2
export WASMLABS_PACKAGE_NAME=libsqlite
