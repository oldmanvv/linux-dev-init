#!/bin/bash

# 遇错退出
set -e

echo "🌐 切换软件源为清华镜像..."
sudo sed -i 's/\(archive\|security\).ubuntu.com/mirrors.tuna.tsinghua.edu.cn/g' /etc/apt/sources.list

echo "🔄 更新系统..."
sudo apt update && sudo apt upgrade -y

echo "✅ 源站切换完成！"