#!/bin/bash

set -eu

################################################################################
# Create update gitsubmodule PR
################################################################################
#
# 注意
# - このスクリプトは main branch で実行してください
#
# 概要
# - gitsubmodule を最新にする PR を作成
# - 古い PR があれば Close して新しく PR を作成
# - 既に最新版の PR があれば作成しない
#
# PR
# - From: main
# - Branch name: update-submodule/${CURRENT_COMMIT_ID}-to-${LATEST_COMMIT_ID}
# - To: main
#

readonly SUBMODULE="akiyadego-openapi"
readonly CURRENT_BRANCH="${CURRENT_BRANCH:-$(git branch --show-current)}"
readonly PR_BRANCH_PREFIX="update-submodule"

#
# 現在のブランチが main branch かどうかを調べる
#
function check_current_branch() {
  if [[ $(git branch --show-current) != "main" ]]; then
    echo "👮 Failed: require main branch" >&2
    exit 1
  fi
}

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

function close_pr_and_create_new_pr_if_not_exist_pr() {
  readonly BRANCH_NAME="${PR_BRANCH_PREFIX}/${CURRENT_MODULE_COMMIT_ID:0:8}-to-${LATEST_MODULE_COMMIT_ID:0:8}"
  branch_count=$(gh pr list --search "head:${BRANCH_NAME} is:open" --json title --jq '.[].title' | wc -l | tr -d ' ')
  if [[ "${branch_count}" == 0 ]]; then
    git switch -c "${BRANCH_NAME}" ## 既にあればエラーで落ちる
    git stage "${SUBMODULE}"
    readonly commit_title="chore(deps): update ${SUBMODULE} to ${LATEST_MODULE_COMMIT_ID:0:8}"
    git -c user.name='bot' -c user.email='action@github.com' commit -m "${commit_title}"
    gh pr create --base main --head "${BRANCH_NAME}" --title "${commit_title}" --body ""
  else
    echo 既に PR は作成済みです
  fi
}

function main() {
  check_current_branch
  stash_diff_for_local_dev
  git pull
  store_module_commit_ids
  close_pr_and_create_new_pr_if_not_exist_pr
}

main

echo '============='
echo "${CURRENT_BRANCH}"
echo "${CURRENT_MODULE_COMMIT_ID}"
echo "${LATEST_MODULE_COMMIT_ID}"
echo '============='
