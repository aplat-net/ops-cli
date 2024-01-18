#!/usr/bin/env bash

set -e

# shellcheck disable=SC1091
. ./bin/function/constants.sh
# shellcheck disable=SC1091
. ./bin/function/log.sh

# shellcheck disable=SC2034
CURRENT_PATH="./bin/scripts"
# shellcheck disable=SC2034
COMMAND_CHAIN="$0"

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  # shellcheck disable=SC1091
  . ./bin/help.sh
  exit 0
fi

# shellcheck disable=SC1091
. ./bin/function/scripts-sub-folder.sh "$@"

log::success "命令执行完成"
