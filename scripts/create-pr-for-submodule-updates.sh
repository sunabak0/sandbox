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


readonly SUBMODULE="akiyadego-openapi"
readonly CURRENT_BRANCH="${CURRENT_BRANCH:-$(git branch --show-current)}"

cd "${SUBMODULE}"
git switch main
git stage .
git stash -q
cd -
current_module_commit_id="$(git submodule status | cut -d ' ' -f2)"
readonly current_module_commit_id
git submodule update --init --recursive --remote
latest_module_commit_id="$(git submodule status | sed 's/^+/ /' | cut -d ' ' -f2)"

echo '============='
echo "${WORKING_DIR}"
echo "${CURRENT_BRANCH}"
echo "${current_module_commit_id}"
echo "${latest_module_commit_id}"
echo '============='
