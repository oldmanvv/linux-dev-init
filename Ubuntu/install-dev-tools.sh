#!/bin/bash

# 遇错退出
set -e

# 获取当前用户名
USER_NAME=$(whoami)

# 安装 OpenSSH Server
echo "🔧 安装 OpenSSH Server..."
sudo apt install -y openssh-server

# 安装基础开发工具
echo "🛠️ 安装基础开发工具..."
sudo apt install -y zsh build-essential git curl wget net-tools htop iftop iotop bmon dstat vim tmux screen lm-sensors

# 设置 zsh 为默认 shell（仅当当前不是 zsh 时）
if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s "$(which zsh)"
fi

echo "✅ 基础开发工具安装完成！"