#!/bin/bash

# 确保安装 choosenim
if ! command -v choosenim &> /dev/null
then
    echo "choosenim 未安装，正在安装..."
    curl https://nim-lang.org/choosenim/init.sh -sSf | sh
    source ~/.profile
fi

# 切换到最新稳定版本的 Nim
choosenim stable

# 检查是否安装成功
if ! command -v nim &> /dev/null
then
    echo "Nim 安装失败，请手动修复！"
    exit 1
fi

# 确保 Nim 环境正确
nim --version

# 卸载并重新安装 nimib
nimble uninstall nimib
nimble install nimib

echo "Nim 和 Nimib 安装完成！"

# 确保 pathutils.nim 存在
if [ ! -f "/usr/lib/nim/compiler/pathutils.nim" ]; then
    echo "pathutils.nim 文件缺失，正在手动下载..."
    curl -L https://github.com/nim-lang/Nim/raw/devel/compiler/pathutils.nim -o /usr/lib/nim/compiler/pathutils.nim
    echo "pathutils.nim 下载并安装完成！"
fi

echo "修复完成！你可以重新运行你的程序。"
