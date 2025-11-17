#!/bin/bash

# 遇错退出
set -e

# 安装并配置 Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    git clone https://mirrors.tuna.tsinghua.edu.cn/git/ohmyzsh.git "$HOME/.oh-my-zsh-temp"
    REMOTE=https://mirrors.tuna.tsinghua.edu.cn/git/ohmyzsh.git sh "$HOME/.oh-my-zsh-temp/tools/install.sh" --unattended
    rm -rf "$HOME/.oh-my-zsh-temp"
fi

# 安装 zsh-autosuggestions 插件
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
fi

# 安装 zsh-syntax-highlighting 插件
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
fi

# 启用插件和主题（bira）
sed -i 's/^plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' "$HOME/.zshrc"
sed -i 's/^ZSH_THEME="robbyrussell"/ZSH_THEME="bira"/' "$HOME/.zshrc"

echo "✅ Oh My Zsh 安装和配置完成！"