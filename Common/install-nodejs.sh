#!/bin/bash

# 设置 NVM_DIR 环境变量 (use project directory if it's intended to be local to project)
export NVM_DIR="$HOME/.nvm"

# 下载并安装 nvm (if not already installed):
if [ ! -d "$NVM_DIR" ]; then
  echo "Installing NVM to $NVM_DIR..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
else
  echo "NVM already installed at $NVM_DIR"
fi

# 加载 NVM
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# 添加 NVM bash_completion 如果存在
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# 下载并安装 Node.js (latest in v20 series):
echo "Installing Node.js v20..."
nvm install 20

# Use the installed version
nvm use 20

# 验证 Node.js 版本：
echo "Node.js version:"
node -v

# Enable Corepack and install pnpm:
echo "Enabling pnpm via Corepack..."
corepack enable pnpm

# 验证 pnpm 版本：
echo "pnpm version:"
pnpm -v

echo "✅ Node.js and pnpm installation completed!"