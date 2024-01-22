#!/usr/bin/env bash

#####################################

# opscli test args -x --domain www.aplat.net a.txt b.txt --email "a@a.com" --email "b@b.com
# opscli test args -x --domain www.aplat.net a.txt b.txt --email "a@a.com" -e 'rm /tmp/a.txt'

# shellcheck disable=SC1090
. "${CURRENT_PATH}.sh.def"

parse_args_with_def "$@"

echo "---------------"
echo "args_domain=$args_domain"
echo "args_x=$args_x"
echo "args_email=$args_email"

# 读取 pos_args 的第一种方法
echo "args_POS_ARGS=$args_POS_ARGS"
eval "declare -a pos_args=${args_POS_ARGS#*=}" # 从 args_POS_ARGS 中读取数组
echo "pos_args.length=${#pos_args[@]}"
echo "pos_args[0]=${pos_args[0]}"
echo "pos_args[1]=${pos_args[1]}"
# 读取 pos_args 的第二种方法
echo "-------"
echo "args_pos_args_length=$args_pos_args_length"
for ((i=0; i<args_pos_args_length; i++)); do
  var="args_pos_args_$i"
  echo "args_pos_args_$i=${!var}" 
done

# # input="-e,--email,--xxxx"
# input="-e,-x, -faa"
# output=$(printf "%s" "$input" | grep -o -- "--[^,]*" | head -n 1)
# if [[ -z "$output" ]]; then
#   output=$(printf "%s" "$input" | grep -o -- "-[^,]*" | head -n 1)
# fi
# printf "%s\n" "$output"


