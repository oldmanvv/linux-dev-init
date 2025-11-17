#!/bin/bash

# 遇错退出
set -e

# 获取当前用户名
USER_NAME=$(whoami)

# 配置 sudo 免密码（仅当前用户）
echo "🔐 配置 sudo 免密码..."
echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" | sudo tee "/etc/sudoers.d/dont-prompt-$USER_NAME-for-sudo-password" > /dev/null
sudo chmod 440 "/etc/sudoers.d/dont-prompt-$USER_NAME-for-sudo-password"

echo "✅ sudo 免密码配置完成！"