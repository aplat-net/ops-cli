#!/usr/bin/env bash

# 去除字符串首尾的空格
function trim() {
  local var="$*"
  # remove leading whitespace characters
  var="${var#"${var%%[![:space:]]*}"}"
  # remove trailing whitespace characters
  var="${var%"${var##*[![:space:]]}"}"   
  printf "%s" "$var"
}

# 解析参数中的 flags, options 和 position arguments
# 单独使用的是 flags, 如 --enable
# 需要值的是 options, 如 --email a@a.com
# 其他参数是 position arguments, 如 a.txt
# $1: flags_map
# $2: options_map
# return: 一个关联数组, key 为 flags 和 options 的值, value 为对应的值
#         注意, 返回值中包含一个特殊的 key: POS_ARGS, 用于存储位置参数
# 示例:
#   # 要执行的命令是 opscli test --xxx --domain www.aplat.net a.txt b.txt
#   # 在 test.sh 添加如下代码
#   # 定义 flags_map 和 options_map
#   declare -A flags_map=( ["-x,--xxx"]='xxx' )
#   declare -A opts_map=( ["-d,--domain"]='domain' ["-e,--email"]='email' )
#   # 调用参数解析方法
#   parse_args "$(declare -p flags_map)" "$(declare -p opts_map)" "$@"
#   # 为要读取的参数定义变量
#   declare -A args
#   declare -a pos_args
#   # 读取 args
#   eval "$(parse_args "$(declare -p flags_map)" "$(declare -p opts_map)" "$@")"
#   # 读取 position arguments
#   eval "declare -a pos_args=${args["POS_ARGS"]#*=}"
#   # 打印参数
#   echo "FLAG_XXX=${args["xxx"]}"
#   echo "OPT_DOMAIN=${args["domain"]}"
#   echo "OPT_EMAIL=${args["email"]}"
#   echo "POS_ARGS=${pos_args[*]}"
function parse_args() {
  local -A args
  local -a flags options options_default_value pos_args
  local key
  # 接收的 $1, $2 会是这种格式, 其中变量名是外部定义的, 需要转换成内部的
  # declare -A opts_map=([-e,--email]="OPT_EMAIL" [-d,--domain]="OPT_DOMAIN" )
  # 比如上面的这个 opts_map, 需要转成 options_map, 所以要替换前半截内容
  eval "local -A flags_map=${1#*=}"
  eval "local -A options_map=${2#*=}"
  eval "local -A options_default_value_map=${3#*=}"
  # echo "flags_map: $(declare -p flags_map)"
  # echo "options_map: $(declare -p options_map)"
  # echo "options_default_value_map: $(declare -p options_default_value_map)"
  # echo "opts_map: ${opts_map["-e,--email"]}"
  # echo "options_map: ${options_map["-e,--email"]}"
  shift 3
  # 给 options 赋初始值
  for key in "${!options_map[@]}"; do
    options_default_value="${options_default_value_map[$key]}"
    if [[ -n "$options_default_value" ]]; then
      args[${options_map[$key]}]="$options_default_value"
    fi
  done
  while [ -n "$1" ]; do
    # 处理 options
    # shellcheck disable=SC2154
    for key in "${!options_map[@]}"; do
      IFS=',' read -ra options <<< "$key"
      for i in "${options[@]}"; do
        if [[ "$(trim "$i")" == "$1" ]]; then
          args[${options_map[$key]}]="$2"
          shift 2
          continue 3
        fi
      done
    done
    # 处理 flags
    # shellcheck disable=SC2154
    for key in "${!flags_map[@]}"; do
      IFS=',' read -ra flags <<< "$key"
      for i in "${flags[@]}"; do
        if [[ "$(trim "$i")" == "$1" ]]; then
          args[${flags_map[$key]}]="true"
          shift
          continue 3
        fi
      done
    done
    pos_args+=("$1")
    shift
  done
  args["POS_ARGS"]="$(declare -p pos_args)"
  declare -p args
}

# 自动从 def 文件中读取 flags 和 options 配置, 然后解析到全局变量
# 全局变量的命名规则为 args_ + flags 或着 options 的值. 如:
#   -e,--email, 则全局变量为 args_email
#   -h, 则全局变量为 args_h
# 位置参数被放入到 args_POS_ARGS 中, 读取时需要 eval. 如:
#   eval "declare -a pos_args=${args_POS_ARGS#*=}"
#   echo "pos_args[0]=${pos_args[0]}"
function parse_args_with_def() {
  # 从 def 中读取的参数
  local -A def_map def_flags_map def_options_map
  # 要传递给 parse_args 的参数
  local -A flags_map options_map options_default_value_map
  # 全部参数
  local -A args
  # 位置参数
  local -a pos_args

  local key pos arg

  # 读取当前脚本的 def 文件
  # shellcheck disable=SC1090
  . "${CURRENT_PATH}.sh.def"

  # 读取 def_map
  eval "$(get_def)"

  # 获取 def 中定义的 flags 和 options
  eval "def_flags_map=${def_map["flags"]#*=}"
  eval "def_options_map=${def_map["options"]#*=}"
  # declare -p def_flags_map
  # declare -p def_options_map

  flags_map=()
  options_map=()
  options_default_value_map=()

  # 处理 options
  for key in "${!def_options_map[@]}"; do
    # 获取参数名的时候, 要去掉默认值配置
    options_map[${key%%=*}]="$(get_arg_name "${key%%=*}")"
    # 如果有默认值, 提取默认值
    if [[ $key == *"="* ]]; then
      options_default_value_map[${key%%=*}]="${key#*=}"
    fi
  done
  # 处理 flags
  # shellcheck disable=SC2154
  for key in "${!def_flags_map[@]}"; do
    flags_map[$key]="$(get_arg_name "$key")"
  done

  # declare -p flags_map
  # declare -p options_map

  # echo '--------------------'
  # parse_args "$(declare -p flags_map)" "$(declare -p options_map)" "$(declare -p options_default_value_map)" "$@"
  eval "$(parse_args "$(declare -p flags_map)" "$(declare -p options_map)" "$(declare -p options_default_value_map)" "$@")"
  # declare -p args

  # 将参数赋值给 args_xxx 变量
  for key in "${!args[@]}"; do
    # echo "$key: ${args[$key]}"
    # args[$key] 来源于用户输入, 要使用 pringf '%q' 进行转义
    eval "args_$key=$(printf '%q' "${args[$key]}")"
  done

  # 将位置参数赋值给 args_pos_args_0, args_pos_args_1 变量, 并添加 args_pos_args_length
  if [[ ${args[POS_ARGS]} == *"="* ]]; then
    eval "local -a pos_args=${args[POS_ARGS]#*=}"
  else
    local -a pos_args=()
  fi
  # shellcheck disable=SC2034
  args_pos_args_length="${#pos_args[@]}"
  for pos in "${!pos_args[@]}"; do
    eval "args_pos_args_$pos=$(printf '%q' "${pos_args[$pos]}")"
  done
}

# 根据 flags 或着 options 的定义, 获取参数名
# $1: flags 或着 options 的定义, 如 -e,--email 或 -d
# return: 参数名, 如 email 或 d
function get_arg_name() {
  local input output
  input="$1"
  # grep 提取 --xxx 或着 -x, head 是只取第一个, sed 是去掉 -- 或着 -
  output=$(printf "%s" "$input" | grep -o -- "--[^,]*" | head -n 1 | sed 's/--//')
  if [[ -z "$output" ]]; then
    output=$(printf "%s" "$input" | grep -o -- "-[^,]*" | head -n 1 | sed 's/-//')
  fi
  printf "%s\n" "$output"
}

# 获取本机的 IP 地址
function get_local_ip() {
  hostname -I | awk '{print $1}'
}