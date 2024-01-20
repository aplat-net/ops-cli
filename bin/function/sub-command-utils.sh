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
    log::debug "help 文件: ${CURRENT_PATH}.sh.help"
    if [[ -f "${CURRENT_PATH}.sh.help" ]]; then
      # shellcheck disable=SC1090
      output_help_info "${CURRENT_PATH}.sh.help"
      exit 0
    else
      log::error "找不到 ${COLOR_RED}${COMMAND_CHAIN}${COLOR_NONE} 的帮助信息."
      exit 1
    fi
  fi

  log::debug "CURRENT_PATH: $CURRENT_PATH"
  if [[ -f "${CURRENT_PATH}.sh" ]]; then
    # shellcheck disable=SC1090
    . "${CURRENT_PATH}.sh" "$@"
  else
    log::error "无法解析命令 ${COLOR_RED}${COMMAND_CHAIN}${COLOR_NONE}."
    exit 1
  fi
}

# 输出子命令
function output_sub_commands() {
  local sh_file help_file help_description maxlen len
  maxlen=0
  # shellcheck disable=SC2010
  while read -r sh_file; do
    len=${#sh_file}
    if (( len > maxlen )); then
      maxlen=$len
    fi
  done < <(ls -1 "$CURRENT_PATH" | grep -E '^.*\.sh$' | sed 's/\.sh$//g')
  # shellcheck disable=SC2010
  while read -r sh_file; do
    help_file="${sh_file}.sh.help"
    if [[ -f "$CURRENT_PATH/$help_file" ]]; then
      # shellcheck disable=SC1090
      printf "  -  %-""$maxlen""s    %s\n" "$sh_file" "$(source "$CURRENT_PATH/$help_file" description)"
    else
      printf "  -  %-""$maxlen""s\n" "$sh_file"
    fi
  done < <(ls -1 "$CURRENT_PATH" | grep -E '^.*\.sh$' | sed 's/\.sh$//g')
}

function output_help_info() {
  local help_file help_usage help_sub_commands help_flags help_description
  help_file="$1"
  # shellcheck disable=SC1090
  help_description="$(source "$help_file" description)"
  # shellcheck disable=SC1090
  help_sub_commands="$(source "$help_file" sub_commands)"
  # shellcheck disable=SC1090
  help_flags="$(source "$help_file" flags)"
  help_usage="$COMMAND_CHAIN"
  if [[ -n "$help_sub_commands" ]]; then
    help_usage="$help_usage [子命令]"
  fi
  if [[ -n "$help_flags" ]]; then
    help_usage="$help_usage [选项]"
  fi
  echo ""
  echo "描述:"
  echo "  $help_description"
  echo ""

  echo "用法:"
  echo "  $help_usage"
  echo ""

  if [[ -n "$help_sub_commands" ]]; then
    echo "子命令:"
    echo "$help_sub_commands"
    echo ""
  fi

  if [[ -n "$help_flags" ]]; then
    echo "选项:$help_flags"
  fi
}