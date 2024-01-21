#!/usr/bin/env bash

#####################################

# opscli test args -x --domain www.aplat.net a.txt b.txt --email "a@a.com" --email "b@b.com
# opscli test args -x --domain www.aplat.net a.txt b.txt --email "a@a.com" -e 'rm /tmp/a.txt'
declare -A flags_map=( ["-x,--xxx"]='xxx' )
declare -A opts_map=( ["-d,--domain"]='domain' ["-e,--email"]='email' )

echo "opts_map: ${opts_map["-e,--email"]}"
# parse_args "$(declare -p flags_map)" "$(declare -p options_map)" "$@"
parse_args "$(declare -p flags_map)" "$(declare -p opts_map)" "$@"
declare -A args
declare -a pos_args
eval "$(parse_args "$(declare -p flags_map)" "$(declare -p opts_map)" "$@")"
eval "declare -a pos_args=${args["POS_ARGS"]#*=}"

echo "FLAG_XXX=${args["xxx"]}"
echo "FLAG_XXX=${args[xxx]}"
echo "OPT_DOMAIN=${args["domain"]}"
echo "OPT_EMAIL=${args["email"]}"
echo "POS_ARGS=${pos_args[*]}"

echo "==================================================="

# shellcheck disable=SC1090
. "${CURRENT_PATH}.sh.def"

parse_args_with_def "$@"
eval "declare -a pos_args=${args_POS_ARGS#*=}"

echo "---------------"
echo "args_domain=$args_domain"
echo "args_x=$args_x"
echo "args_email=$args_email"
echo "args_POS_ARGS=$args_POS_ARGS"
echo "pos_args[0]=${pos_args[0]}"
echo "pos_args[1]=${pos_args[1]}"


# # input="-e,--email,--xxxx"
# input="-e,-x, -faa"
# output=$(printf "%s" "$input" | grep -o -- "--[^,]*" | head -n 1)
# if [[ -z "$output" ]]; then
#   output=$(printf "%s" "$input" | grep -o -- "-[^,]*" | head -n 1)
# fi
# printf "%s\n" "$output"


