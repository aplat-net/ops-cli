#!/usr/bin/env bash

sed -i '/##OPS_CLI_MARK/d' ~/.zshrc
echo "
# 环境变量使用 HOME_OF_OPS_CLI, 而不是 OPS_CLI_HOME, 是因为 OPS_CLI_HOME 会在输入 ops <tab> 的时候自动提示出来. ##OPS_CLI_MARK
export HOME_OF_OPS_CLI='$(realpath .)' ##OPS_CLI_MARK
export PATH=\"\$HOME_OF_OPS_CLI:\$PATH\" ##OPS_CLI_MARK
fpath=(\${HOME_OF_OPS_CLI}/bin/data/opscli/completions/zsh \$fpath) ##OPS_CLI_MARK
# 修改完 fpath 之后, 要调用 compinit 重新初始化. ##OPS_CLI_MARK
compinit ##OPS_CLI_MARK
" >> ~/.zshrc

log::info "安装完成"