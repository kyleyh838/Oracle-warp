#!/bin/bash

sudo lsattr /etc/passwd /etc/shadow
sudo chattr -i /etc/passwd /etc/shadow
sudo chattr -a /etc/passwd /etc/shadow
sudo lsattr /etc/passwd /etc/shadow

read -p "自定义ROOT密码:" mima
echo root:$mima | sudo chpasswd root
read -p "自定义SSH端口:" port
sudo sed -i 's/^#\?Port.*/Port $port@/g' /etc/ssh/sshd_config;
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config;
sudo sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config;
sudo systemctl restart ssh.service
