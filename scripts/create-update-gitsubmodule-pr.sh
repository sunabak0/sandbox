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
cd akiyadego-openapi && git switch main && git restore .
git submodule status akiyadego-openapi | tr -d ' ' | sed 's/^+//'

