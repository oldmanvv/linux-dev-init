#!/bin/bash

# 遇错退出
set -e

# 安装 uv (提供 uvx 工具)
echo "⚡ 安装 uv (uvx)..."
if ! command -v uvx >/dev/null 2>&1 && ! command -v uv >/dev/null 2>&1; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# 当前会话与持久化 PATH 设置
export PATH="$HOME/.local/bin:$PATH"
if ! grep -q '\.local/bin' "$HOME/.zshrc"; then
  printf '\n# uv installs to ~/.local/bin\nexport PATH="$HOME/.local/bin:$PATH"\n' >> "$HOME/.zshrc"
fi

echo "✅ uv 安装完成！"