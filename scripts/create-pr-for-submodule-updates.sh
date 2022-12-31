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
git stash -q -m "$(date +%Y-%m-%dT%H:%M:%S) : create-pr-for-submodule-udpates によって stash しました" > /dev/null
cd -
git submodule deinit -f "${SUBMODULE}" > /dev/null
echo '---'
git submodule status
echo '---'
current_module_commit_id="$(git submodule status | sed 's/^-//' | cut -d ' ' -f1)"
readonly current_module_commit_id
git submodule update --init --recursive --remote -q
latest_module_commit_id="$(git submodule status | sed 's/^+//' | cut -d ' ' -f1)"

echo '============='
git submodule status
echo "${CURRENT_BRANCH}"
echo "${current_module_commit_id}"
echo "${latest_module_commit_id}"
echo '============='
