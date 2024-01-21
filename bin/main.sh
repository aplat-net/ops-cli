#!/usr/bin/env bash

# shellcheck disable=SC2034
CURRENT_PATH="./bin/scripts"
# shellcheck disable=SC2034
COMMAND_CHAIN="$(basename "$0")"

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  # shellcheck disable=SC1091
  output_help_info_from_help "./bin/main.sh.help"
  exit 0
fi

handle_sub_command "$@"

log::success "命令执行完成"
