#!/bin/bash

# 遇错不立即退出，以便用户可以继续选择其他选项
set +e

# 检测Linux发行版
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$NAME
        DISTRO_ID=$ID
    else
        echo "❌ 无法检测Linux发行版"
        exit 1
    fi
}

# 显示脚本菜单
show_menu() {
    echo ""
    echo "=========================================="
    echo "🚀 Linux 开发环境配置脚本菜单"
    echo "=========================================="
    echo ""
    echo "检测到的发行版: $DISTRO ($DISTRO_ID)"
    echo ""
    echo "请选择要执行的脚本:"
    echo ""
    echo "  Ubuntu 相关脚本:"
    echo "  1.  配置 sudo 免密码 (Ubuntu) - 设置当前用户执行sudo命令时无需输入密码"
    echo "  2.  切换软件源为清华镜像 (Ubuntu) - 将APT源切换为清华镜像以提高下载速度"
    echo "  3.  安装基础开发工具 (Ubuntu) - 安装zsh、build-essential、git等基础开发工具"
    echo "  4.  安装 Docker (Ubuntu) - 安装Docker及Docker Compose"
    echo "  5.  WSL安装CUDA (Ubuntu) - 为WSL环境安装CUDA工具包"
    echo ""
    echo "  通用脚本:"
    echo "  6.  配置 CUDA 版本管理工具 - 提供CUDA版本切换功能的命令行工具"
    echo "  7.  安装 Miniconda - 安装轻量级Python环境管理工具"
    echo "  8.  安装 NVM 和 Node.js - 安装Node版本管理器及Node.js"
    echo "  9.  安装 Oh My Zsh - 安装并配置Oh My Zsh增强shell体验"
    echo "  10. 安装 uv - 安装快速Python包管理工具"
    echo ""
    echo "  0.  退出"
    echo ""
    echo "=========================================="
    echo -n "请输入选项编号 (0-10): "
}

# 执行脚本函数
execute_script() {
    local script_path=$1
    local script_name=$2
    local script_desc=$3

    echo ""
    echo "🔍 正在执行: $script_name"
    echo "📝 描述: $script_desc"
    echo "📁 脚本路径: $script_path"
    echo "------------------------------------------"

    if [ -f "$script_path" ]; then
        if source "$script_path"; then
            echo "✅ $script_name 执行成功！"
        else
            echo "❌ $script_name 执行失败！退出码: $?"
        fi
    else
        echo "❌ 脚本不存在: $script_path"
    fi

    echo "------------------------------------------"
    echo "按任意键继续..."
    read -n 1 -s
}

# 主程序
main() {
    detect_distro

    # 检查是否为支持的发行版
    if [ "$DISTRO_ID" != "ubuntu" ]; then
        echo "⚠️  当前只支持Ubuntu发行版，检测到: $DISTRO"
        echo "💡  即将退出..."
        exit 1
    fi

    # 设置脚本路径
    UBUNTU_DIR="./Ubuntu"
    COMMON_DIR="./Common"

    while true; do
        clear
        show_menu
        read choice

        case $choice in
            1)
                execute_script "$UBUNTU_DIR/config-sudo-nopasswd.sh" "配置 sudo 免密码" "设置当前用户执行sudo命令时无需输入密码"
                ;;
            2)
                execute_script "$UBUNTU_DIR/changesource.sh" "切换软件源为清华镜像" "将APT源切换为清华镜像以提高下载速度"
                ;;
            3)
                execute_script "$UBUNTU_DIR/install-dev-tools.sh" "安装基础开发工具" "安装zsh、build-essential、git等基础开发工具"
                ;;
            4)
                execute_script "$UBUNTU_DIR/install-docker.sh" "安装 Docker" "安装Docker及Docker Compose"
                ;;
            5)
                echo ""
                echo "🔍 正在执行: WSL安装CUDA"
                echo "📝 描述: 为WSL环境安装CUDA工具包"
                echo "📁 脚本路径: $UBUNTU_DIR/wsl-install-cuda.sh"
                echo "------------------------------------------"
                echo "💡 此脚本需要CUDA版本作为参数，例如: 12.4"
                echo -n "请输入要安装的CUDA版本 (例如 12.4): "
                read cuda_version
                if [ -f "$UBUNTU_DIR/wsl-install-cuda.sh" ]; then
                    if bash "$UBUNTU_DIR/wsl-install-cuda.sh" "$cuda_version"; then
                        echo "✅ WSL安装CUDA 执行成功！"
                    else
                        echo "❌ WSL安装CUDA 执行失败！退出码: $?"
                    fi
                else
                    echo "❌ 脚本不存在: $UBUNTU_DIR/wsl-install-cuda.sh"
                fi
                echo "------------------------------------------"
                echo "按任意键继续..."
                read -n 1 -s
                ;;
            6)
                execute_script "$COMMON_DIR/cuda-version-manager.sh" "配置 CUDA 版本管理工具" "提供CUDA版本切换功能的命令行工具"
                ;;
            7)
                execute_script "$COMMON_DIR/install-miniconda.sh" "安装 Miniconda" "安装轻量级Python环境管理工具"
                ;;
            8)
                execute_script "$COMMON_DIR/install-nvm-nodejs.sh" "安装 NVM 和 Node.js" "安装Node版本管理器及Node.js"
                ;;
            9)
                execute_script "$COMMON_DIR/install-ohmyzsh.sh" "安装 Oh My Zsh" "安装并配置Oh My Zsh增强shell体验"
                ;;
            10)
                execute_script "$COMMON_DIR/install-uv.sh" "安装 uv" "安装快速Python包管理工具"
                ;;
            0)
                echo ""
                echo "👋 感谢使用 Linux 开发环境配置脚本！"
                echo "💡 建议操作："
                echo "  - 重新登录终端以应用 ZSH 和 Conda 配置"
                echo "  - 如需 SSH 免密登录，请手动执行：ssh-copy-id user@host"
                echo "  - 如需立即重启（推荐，因可能包含内核更新），请运行：sudo reboot"
                echo ""
                exit 0
                ;;
            *)
                echo ""
                echo "❌ 无效选项，请输入 0-10 之间的数字"
                echo "按任意键继续..."
                read -n 1 -s
                ;;
        esac
    done
}

# 启动主程序
main