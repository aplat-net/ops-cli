#!/usr/bin/env bash

# 本文件提供了一些函数, 用于解析子命令, 并调用对应的脚本文件.

function handle_sub_command() {
  if [[ -z "$1" ]]; then
    log::error "命令不完整, 请使用 $COMMAND_CHAIN --help 查看帮助信息."
    exit 1
  fi
  # 处理子命令
  CURRENT_PATH="$CURRENT_PATH/$1"
  COMMAND_CHAIN="${COMMAND_CHAIN} $1"
  shift

  # 处理帮助信息
  if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    log::debug "${CURRENT_PATH}.help"
    if [[ -f "${CURRENT_PATH}.help" ]]; then
      # shellcheck disable=SC1090
      . "${CURRENT_PATH}.help"
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
}

function output_sub_commands() {
  # 输出子命令
  # shellcheck disable=SC2010
  while read -r line; do
    echo "  $line"
  done < <(ls -1 "$CURRENT_PATH" | grep -E '^.*\.sh$' | grep -v '_help.sh' | sed 's/\.sh$//g')
}
