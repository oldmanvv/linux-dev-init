#!/bin/bash

# 遇错退出
set -e

# 安装 Miniconda（轻量版 Conda，推荐）
echo "🐍 安装 Miniconda（使用清华源）..."
CONDA_SCRIPT="Miniconda3-latest-Linux-$(uname -m).sh"
CONDA_URL="https://mirrors.tuna.tsinghua.edu.cn/anaconda/miniconda/Miniconda3-latest-Linux-x86_64.sh"

if [ ! -f "$HOME/miniconda3/bin/conda" ]; then
    curl -LO "$CONDA_URL" -o "~/tmp/$CONDA_SCRIPT"
    bash "~/tmp/$CONDA_SCRIPT" -b -p "$HOME/miniconda3"
    "$HOME/miniconda3/bin/conda" init zsh
    # 配置清华镜像
    cat > "$HOME/.condarc" <<EOF
channels:
  - defaults
show_channel_urls: true
default_channels:
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/r
  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/msys2
custom_channels:
  conda-forge: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
  pytorch: https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud
EOF
fi

# 清理
rm -f "~/tmp/"

echo "✅ Miniconda 安装完成！"