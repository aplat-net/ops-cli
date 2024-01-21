#!/usr/bin/env bash

# 本文件提供了一些函数, 用于解析子命令, 并调用对应的脚本文件.
# 使用本方法的另一个好处是可以将子命令的内容都放到 function 的作用域下, 避免全局污染
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
      output_help_info_from_help "${CURRENT_PATH}.sh.help"
      exit 0
    elif [[ -f "${CURRENT_PATH}.sh.def" ]]; then
      # shellcheck disable=SC1090
      output_help_info_from_def "${CURRENT_PATH}.sh.def"
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
      printf "  -  %-""$maxlen""s    %s\n" "$sh_file" "$(source "$CURRENT_PATH/$help_file" short_description)"
    else
      printf "  -  %-""$maxlen""s\n" "$sh_file"
    fi
  done < <(ls -1 "$CURRENT_PATH" | grep -E '^.*\.sh$' | sed 's/\.sh$//g')
}

function output_help_info_from_help() {
  local help_file 
  local help_usage help_sub_commands help_flags help_short_description help_description
  help_file="$1"
  # shellcheck disable=SC1090
  help_short_description="$(source "$help_file" short_description)"
  # shellcheck disable=SC1090
  help_description="$(source "$help_file" description)"
  # shellcheck disable=SC1090
  help_sub_commands="$(source "$help_file" sub_commands)"
  # shellcheck disable=SC1090
  help_flags="$(source "$help_file" flags)"
  # shellcheck disable=SC1090
  help_usage="$(source "$help_file" usage)"

  output_help_info "$help_usage" "$help_sub_commands" "$help_flags" "$help_short_description" "$help_description"
}

function output_help_info_from_def() {
  local def_file
  local help_usage help_sub_commands help_flags help_short_description help_description
  local maxlen len
  # 从 def 中读取的参数
  local -A def_map def_flags_map def_options_map
  def_file="$1"

  # 引入 def 文件
  # shellcheck disable=SC1090
  . "$def_file"

  # 读取 def_map
  eval "$(get_def)"

  # 获取 def 中定义的 flags 和 options
  eval "def_flags_map=${def_map["flags"]#*=}"
  eval "def_options_map=${def_map["options"]#*=}"

  maxlen=0
  # 计算最长的 flags/options, 为格式化做准备
  for key in "${!def_options_map[@]}"; do
    len=${#key}
    if (( len > maxlen )); then
      maxlen=$len
    fi
  done
  # shellcheck disable=SC2154
  for key in "${!def_flags_map[@]}"; do
    len=${#key}
    if (( len > maxlen )); then
      maxlen=$len
    fi
  done

  for key in "${!def_options_map[@]}"; do
    help_flags="$help_flags\n$(printf "  %-""$maxlen""s    %s\n" "$key" "${def_options_map[$key]}")"
  done
  # shellcheck disable=SC2154
  for key in "${!def_flags_map[@]}"; do
    help_flags="$help_flags\n$(printf "  %-""$maxlen""s    %s\n" "$key" "${def_flags_map[$key]}")"
  done

  echo -e "$help_flags"
  help_sub_commands="${def_map["sub_commands"]}"
  help_short_description="${def_map["short_description"]}"
  help_description="${def_map["description"]}"

  output_help_info "$help_usage" "$help_sub_commands" "$help_flags" "$help_short_description" "$help_description"
}

function output_help_info() {
  local help_usage help_sub_commands help_flags help_short_description help_description
  help_usage="$1"
  help_sub_commands="$2"
  help_flags="$3"
  help_short_description="$4"
  help_description="$5"


  if [[ -z "$help_usage" ]]; then
    help_usage="$COMMAND_CHAIN"
    if [[ -n "$help_sub_commands" ]]; then
      help_usage="$help_usage [子命令]"
    fi
    if [[ -n "$help_flags" ]]; then
      help_usage="$help_usage [选项]"
    fi
  fi

  echo ""
  echo "描述:"
  echo "  $help_short_description"
  if [[ -n "$help_description" ]]; then
    echo "  $help_description"
  fi
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
    echo -e "选项:$help_flags"
  fi
}