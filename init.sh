#!/bin/bash

# 遇错退出
set -e

# 获取当前用户名
USER_NAME=$(whoami)

# 2. 配置 sudo 免密码（仅当前用户）
echo "🔐 配置 sudo 免密码..."
echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" | sudo tee "/etc/sudoers.d/dont-prompt-$USER_NAME-for-sudo-password" > /dev/null
sudo chmod 440 "/etc/sudoers.d/dont-prompt-$USER_NAME-for-sudo-password"


# 3. 切换软件源为清华镜像
echo "🌐 切换软件源为清华镜像..."
sudo sed -i 's/\(archive\|security\).ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list

# 4. 更新系统
echo "🔄 更新系统..."
sudo apt update && sudo apt upgrade -y

# 1. 安装 OpenSSH Server
echo "🔧 安装 OpenSSH Server..."
sudo apt install -y openssh-server

# 5. 安装基础开发工具
echo "🛠️ 安装基础开发工具..."
sudo apt install -y zsh build-essential git curl wget net-tools htop iftop iotop bmon dstat vim tmux screen lm-sensors

# 设置 zsh 为默认 shell（仅当当前不是 zsh 时）
if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s "$(which zsh)"
fi

# 7. 安装并配置 Oh My Zsh

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

# 注入 CUDA 版本管理工具到 Zsh（idempotent）
echo "🧰 配置 CUDA 版本管理工具到 Zsh..."
CUDA_HELPER="$HOME/.cuda-zsh-helper"
if [ ! -f "$CUDA_HELPER" ]; then
  cat > "$CUDA_HELPER" <<'ZSHCUDA'
# CUDA 版本管理工具（无 sudo，仅当前 shell 环境）
cudas() {
  local cuda_root_base="/usr/local"
  local cmd="$1"
  local version="$2"
  local default_file="${HOME}/.cuda_default"

  case "$cmd" in
    list)
      echo "🧭 Available CUDA versions:"
      ls -d ${cuda_root_base}/cuda-* 2>/dev/null | sed "s|${cuda_root_base}/cuda-||" | sort -V
      ;;
    use)
      if [[ -z "$version" ]]; then
        echo "Usage: cudas use <version>"
        echo "Example: cudas use 12.4"
        return 1
      fi

      local target_path="${cuda_root_base}/cuda-${version}"
      if [[ ! -d "$target_path" ]]; then
        echo "❌ CUDA version ${version} not found at ${target_path}"
        return 1
      fi

      # 清除旧 CUDA 路径
      export PATH=$(echo "$PATH" | tr ':' '\n' | grep -v '/usr/local/cuda' | grep -v '/cuda-[0-9]' | paste -sd:)
      export LD_LIBRARY_PATH=$(echo "${LD_LIBRARY_PATH:-}" | tr ':' '\n' | grep -v '/usr/local/cuda' | grep -v '/cuda-[0-9]' | paste -sd:) 2>/dev/null || true

      # 设置新环境
      export CUDA_HOME="${target_path}"
      export PATH="${CUDA_HOME}/bin:${PATH}"
      if [[ -d "${CUDA_HOME}/lib64" ]]; then
        export LD_LIBRARY_PATH="${CUDA_HOME}/lib64:${LD_LIBRARY_PATH:-}"
      fi

      echo "✅ Switched to CUDA ${version}"
      nvcc --version 2>/dev/null | grep release || echo "⚠️ nvcc not found in PATH"
      ;;
    current)
      if [[ -n "$CUDA_HOME" ]]; then
        echo "🔹 Current CUDA: ${CUDA_HOME}"
        nvcc --version 2>/dev/null | grep release || echo "⚠️ nvcc not found in PATH"
      else
        echo "ℹ️ No CUDA version currently active"
      fi
      ;;
    default)
      if [[ -z "$version" ]]; then
        if [[ -f "$default_file" ]]; then
          echo "💾 Default CUDA version: $(cat "$default_file")"
        else
          echo "ℹ️ No default CUDA version set"
        fi
      else
        local target_path="${cuda_root_base}/cuda-${version}"
        if [[ ! -d "$target_path" ]]; then
          echo "❌ CUDA version ${version} not found at ${target_path}"
          return 1
        fi
        echo "$version" > "$default_file"
        echo "✅ Default CUDA version set to ${version}"
      fi
      ;;
    *)
      echo "Usage:"
      echo "  cudas list             # List available CUDA versions"
      echo "  cudas use <version>    # Switch to specified version"
      echo "  cudas current          # Show current CUDA version"
      echo "  cudas default <ver>    # Set default version"
      echo "  cudas default          # Show current default version"
      ;;
  esac
}

# 自动加载默认 CUDA 版本
if [[ -f "${HOME}/.cuda_default" ]]; then
  default_ver=$(cat "${HOME}/.cuda_default")
  cudas use "$default_ver" >/dev/null 2>&1 && echo "🎯 Loaded default CUDA ${default_ver}"
fi

alias nvitop="uvx nvitop"
alias glances="uvx glances"
ZSHCUDA
fi

# 确保在 .zshrc 中加载该工具（避免重复添加）
if ! grep -q 'source "$HOME/.cuda-zsh-helper"' "$HOME/.zshrc"; then
  printf '\n# Load CUDA version manager\n[ -f "$HOME/.cuda-zsh-helper" ] && source "$HOME/.cuda-zsh-helper"\n' >> "$HOME/.zshrc"
fi


# 8. 安装 Docker（使用清华源）
echo "🐳 安装 Docker..."
sudo apt install -y ca-certificates curl gnupg lsb-release
curl -fsSL https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://mirrors.tuna.tsinghua.edu.cn/docker-ce/linux/ubuntu/ $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo usermod -aG docker "$USER_NAME"

# 9. 安装 NVM（Node 版本管理器）并安装 Node.js LTS
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

# 10. 安装 Miniconda（轻量版 Conda，推荐）或 Anaconda
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


echo "✅ 初始化完成！"
echo "💡 建议操作："
echo "  - 重新登录终端以应用 ZSH 和 Conda 配置"
echo "  - 如需 SSH 免密登录，请手动执行：ssh-copy-id user@host"
echo "  - 如需立即重启（推荐，因可能包含内核更新），请运行：sudo reboot"