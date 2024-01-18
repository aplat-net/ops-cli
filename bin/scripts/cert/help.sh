#!/usr/bin/env bash

echo "
https 证书操作

用法: 
  $COMMAND_CHAIN [子命令] [选项]

子命令: "

# scripts 目录下的 *.sh 都是子命令
# shellcheck disable=SC2010
while read -r line; do
  echo "  $line"
done < <(ls -1 ./bin/scripts/cert | grep -E '^.*\.sh$' | sed 's/\.sh$//g')

echo "
选项:
  -h, --help    显示帮助信息

如果想要打印调试信息, 请设置 export OPS_CLI_DEBUG=true
"
