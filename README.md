# Ops CLI

## 文件结构

```
├── bin
│   ├── function       公共方法
│   ├── scripts        脚本文件
│   ├── data           一般数据, 如脚本依赖的资源文件等
│   ├── secret         敏感数据, 如秘钥, 证书文件等
│   └── main.sh        主方法
├── opscli             入口
```

### scripts 结构

对于子命令, 统一放到 scripts 目录下, 每个子命令对应一个 `.sh` 文件和一个目录, 目录是用来存放子命令的.

如下是一个基本的 scripts 目录结构, 其中包含三个子命令 `cert`, `self` 和 `test`.

```
bin/scripts
├── cert
│   ├── gen.sh
│   └── gen.sh.help
├── self
│   ├── install-bash-completion.sh  
│   └── install-zsh-completion.sh
├── cert.sh
├── cert.sh.help
├── self.sh
├── self.sh.help
└── test.sh
```

首先看 `test` 命令, 它只有 `test.sh` 文件, 没有对应的 `test` 目录. 这是因为它是第一个简单的命令, 不包含子命令, 所以不需要有目录. `test.sh` 文件内容比较简单, 可以自行查看.

然后再看 `cert`, 首先有一个 `cert.sh` 文件, 内容如下

```bash
#!/usr/bin/env bash
handle_sub_command "$@"
```

与 `test.sh` 直接提供功能不同, 它是一个子命令的入口, 它引用了 `sub-command-utils.sh` 的 `handle_sub_command` 方法. 这个方法的作用是提供子命令的解析, 比如 `opscli cert gen` 会对应到 `bin/scripts/cert/gen.sh` 文件, 并提供 `--help` 的支持.

### --help 支持

帮助文档对于使用者来说非常重要, 这里直接对 `--help` 做了特殊支持. 

还是以 `cert` 命令为例, 与 `cert.sh` 一起的还有一个 `cert.sh.help` 文件, 内容如下

```bash
#!/usr/bin/env bash

# short_description 是命令的简短介绍
if [[ "$1" == "short_description" ]]; then

  echo "https 证书操作"

# description 是命令的详细介绍
elif [[ "$1" == "description" ]]; then

  echo "生成 https 证书等"

# sub_commands 是子命令列表, 这里使用 output_sub_commands 来通过 cert 目录获取子命令列表, 同时会用子命令的 short_description 作为介绍
elif [[ "$1" == "sub_commands" ]]; then

  # shellcheck disable=SC2005
  echo "$(output_sub_commands)"

# 支持的选项列表
elif [[ "$1" == "flags" ]]; then

  echo "
  -h,--help    显示帮助信息
"

fi

```

### 自动补全支持

执行 `opscli self install-bash-completion` 和 `opscli sellf install-zsh-completion` 会将自动补全脚本配置到系统中

配置完之后, 重启 Terminal 可以对 `opscli` 的子命令进行自动补全(按 Tab). 自动补全是基于目录结构进行的, 新加入的子命令会自动被读取出来, 不需要重新安装自动补全脚本.

自动补全分为如下几种

- 子命令, 会按照目录查找子命令, 然后进行自动补全
- 选项, 会按照 `*.sh.help` 中 `flags` 部分自动提取.
- `*.sh.comp` 文件, 如果有定义的 `*.sh.comp` 文件, 则会优先用它, 跳过上面的两种方式. 例如:
```bash
echo "--test -t test"
```

### Log 文件

opscli 会将 log 存到 logs 目录下.

其中 `log::trace` 只会输出到 log 文件中

`log::debug` 默认也只会输出到 log 文件中, 但如果设置了 `export OPS_CLI_DEBUG=true` 则也会输出到 Terminal


