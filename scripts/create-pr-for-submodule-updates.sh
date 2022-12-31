#!/bin/bash

set -eu

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
readonly PR_BRANCH_PREFIX="update-submodule"

#
# ローカル開発環境用
# - 作業中の場合は stash 領域に退避
#   - 別関数の、 `git submodule deinit -f` で作業分が消えてしまうため
#
function stash_diff_for_local_dev() {
  cd "${SUBMODULE}" || exit 1
  git switch main
  git stage .
  git stash -q -m "$(date +%Y-%m-%dT%H:%M:%S) : create-pr-for-submodule-udpates によって stash しました" > /dev/null
  cd - || exit 1
}

#
# 最新状態の main branch に切り替え
#
function switch_latest_main_branch() {
  git fetch main
  git switch main
  git pull
}

#
# - 現在の submodule の commit id を取得
# - 最新の submodule の commit id を取得
# - `git submodule deinit -f` している理由
#   - CI 上で現状の submodule の commit id を取得できなかったため
#
function store_module_commit_ids() {
  git submodule deinit -f "${SUBMODULE}" > /dev/null
  CURRENT_MODULE_COMMIT_ID="$(git submodule status | sed 's/^-//' | cut -d ' ' -f1)"
  readonly CURRENT_MODULE_COMMIT_ID
  git submodule update --init --recursive --remote -q
  LATEST_MODULE_COMMIT_ID="$(git submodule status | sed 's/^+//' | cut -d ' ' -f1)"
  readonly LATEST_MODULE_COMMIT_ID
}

function exist_pr() {
  readonly BRANCH_NAME="${PR_BRANCH_PREFIX}/${CURRENT_MODULE_COMMIT_ID:0:4}-to-${LATEST_MODULE_COMMIT_ID:0:4}"
  gh pr list --search "head:${BRANCH_NAME} is:open" --json title --jq '.[].title'
}

function main() {
  stash_diff_for_local_dev
  switch_latest_main_branch
  store_module_commit_ids
  git switch -
}

main

echo '============='
echo "${CURRENT_BRANCH}"
echo "${CURRENT_MODULE_COMMIT_ID}"
echo "${LATEST_MODULE_COMMIT_ID}"
echo '============='
