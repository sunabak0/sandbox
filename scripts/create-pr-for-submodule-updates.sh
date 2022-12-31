#!/bin/bash

################################################################################
# Create update gitsubmodule PR
################################################################################
#
# 概要
# - gitsubmodule を最新にする PR を作成
# - 古い PR があれば Close して新しく PR を作成
# - 既に最新版の PR があれば作成しない
#
# PR
# - From: main
# - Branch name: update-submodule/${LATEST_COMMIT_ID}
# - To: main
#

git submodule update --init --recursive --remote

readonly WORKING_DIR="$(git rev-parse --show-toplevel)"
readonly SUBMODULE="akiyadego-openapi"
readonly CURRENT_BRANCH="${CURRENT_BRANCH:-$(git branch --show-current)}"
readonly CURRENT_SUBMODULE_COMMIT_ID="$(cat ${WORKING_DIR}/.git/modules/${SUBMODULE}/ORIG_HEAD)"
readonly LATEST_SUBMODULE_COMMIT_ID="$(cat ${WORKING_DIR}/.git/modules/${SUBMODULE}/HEAD)"

#cd akiyadego-openapi && git switch main && git restore .
#git submodule status akiyadego-openapi | tr -d ' ' | sed 's/^+//'

echo '============='
echo "${WORKING_DIR}"
echo "${CURRENT_BRANCH}"
echo "${CURRENT_SUBMODULE_COMMIT_ID}"
echo "${LATEST_SUBMODULE_COMMIT_ID}"
echo '============='
