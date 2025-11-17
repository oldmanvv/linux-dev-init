#!/bin/bash

# 遇错退出
set -e

# 安装 NVM（Node 版本管理器）并安装 Node.js LTS
echo "🟢 安装 NVM 并安装 Node.js LTS..."
export NVM_VERSION="v0.40.3"
if [ ! -d "$HOME/.nvm" ]; then
  curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh | bash
fi

# 通过当前 shell 加载 nvm（适配 zsh 及 bash）
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then . "$NVM_DIR/nvm.sh"; fi
if [ -s "$NVM_DIR/bash_completion" ]; then . "$NVM_DIR/bash_completion"; fi

# 持久化 NVM 镜像设置到 zsh 配置（便于后续手动安装 Node.js）
if ! grep -q 'NVM_NODEJS_ORG_MIRROR' "$HOME/.zshrc"; then
  echo 'export NVM_NODEJS_ORG_MIRROR="https://mirrors.tuna.tsinghua.edu.cn/nodejs-release"' >> "$HOME/.zshrc"
fi

echo "🔵 需要手动通过nvm安装需要的 Node.js 版本"
echo "✅ NVM 安装完成！"