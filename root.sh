#!/bin/bash

# 检查并修改文件属性
sudo lsattr /etc/passwd /etc/shadow
sudo chattr -i /etc/passwd /etc/shadow
sudo chattr -a /etc/passwd /etc/shadow
sudo lsattr /etc/passwd /etc/shadow
SSHD_CONFIG=/etc/ssh/sshd_config

# 自定义设置
read -p "输入新ROOT密码 (留空则不更改): " mima
if [[ -n "$mima" ]]; then
    echo "正在设置root密码..."
    echo "root:$mima" | sudo chpasswd
    if [[ $? -eq 0 ]]; then
        echo "root密码已成功更新。"
    else
        echo "设置root密码失败。请检查权限或输入是否正确。"
        exit 1
    fi
else
    echo "未输入密码，跳过设置root密码。"
fi

read -p "输入新SSH端口 (默认端口22): " port
if [[ -z "$port" ]]; then
    port=22
    echo "未输入端口，使用默认端口22。"
else
    if ! [[ "$port" =~ ^[0-9]+$ ]] || [[ "$port" -lt 1 || "$port" -gt 65535 ]]; then
        echo "无效的端口号。请输入1-65535之间的数字。"
        exit 1
    fi
    echo "SSH端口变更为：$port"
fi

# SSH设置
sudo cp "$SSHD_CONFIG" "${SSHD_CONFIG}.bak"
sudo sed -i "s@^#Port.*@&\nPort $port@" "$SSHD_CONFIG"
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' "$SSHD_CONFIG"
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' "$SSHD_CONFIG"

# 重启SSH服务
sudo systemctl restart ssh.service
echo "SSH服务已重启。"

# 是否调整防火墙设置
read -p "是否调整防火墙设置以允许所有流量？(y/n): " fw_choice

if [[ "$fw_choice" =~ ^[Yy]$ ]]; then
    echo "正在调整防火墙设置..."
    sudo iptables -P INPUT ACCEPT
    sudo iptables -P FORWARD ACCEPT
    sudo iptables -P OUTPUT ACCEPT
    sudo iptables -F
    sudo apt-get purge netfilter-persistent -y
    echo "防火墙设置已更新。"
else
    echo "跳过防火墙设置。"
fi

# 是否重启系统
read -p "是否立即重启系统以应用所有更改？(y/n): " reboot_choice

if [[ "$reboot_choice" =~ ^[Yy]$ ]]; then
    echo "设置完成，即将重启系统..."
    sudo reboot
else
    echo "设置完成，重启已跳过，请稍后手动重启系统以应用更改。"
fi
