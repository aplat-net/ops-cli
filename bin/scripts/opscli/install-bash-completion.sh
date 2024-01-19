#!/usr/bin/env bash

sed -i '/##OPS_CLI_MARK/d' ~/.bashrc
echo "
export HOME_OF_OPS_CLI='$(realpath .)' ##OPS_CLI_MARK
export PATH=\"\$HOME_OF_OPS_CLI:\$PATH\" ##OPS_CLI_MARK
source \"\${HOME_OF_OPS_CLI}/bin/data/opscli/completions/bash/_opscli\" ##OPS_CLI_MARK
complete -F _opscli::completion 'opscli' ##OPS_CLI_MARK
" >> ~/.bashrc

log::info "安装完成"