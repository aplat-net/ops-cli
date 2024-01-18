#!/usr/bin/env bash

# 本文件提供了一个函数, 用于解析子命令, 并调用对应的脚本文件.

# 处理子命令
CURRENT_PATH="$CURRENT_PATH/$1"
COMMAND_CHAIN="${COMMAND_CHAIN} $1"
shift

# 处理帮助信息
if [[ "$1" == "--help" || "$1" == "-h" ]]; then
  log::debug "${CURRENT_PATH}/help.sh"
  if [[ -f "${CURRENT_PATH}/help.sh" ]]; then
    # shellcheck disable=SC1091
    . "${CURRENT_PATH}/help.sh"
    exit 0
  else
    log::error "找不到 ${COLOR_RED}${COMMAND_CHAIN}${COLOR_NONE} 的帮助信息."
    exit 1
  fi
fi

log::debug "$CURRENT_PATH"
if [[ -f "${CURRENT_PATH}.sh" ]]; then
  # shellcheck disable=SC1090
  . "${CURRENT_PATH}.sh" "$@"
else
  log::error "无法解析命令 ${COLOR_RED}${COMMAND_CHAIN}${COLOR_NONE}."
  exit 1
fi
