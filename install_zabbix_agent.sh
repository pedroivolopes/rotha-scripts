#!/bin/bash

# ================================================
# Zabbix Agent 2 - Instalador Automático
# Proxy: 192.168.10.254
# RothaDigital - Pedro Ivo
# ================================================

set -e

PROXY_IP="192.168.10.254"
ZABBIX_VERSION="7.4"
HOSTNAME=$(hostname)

echo "=========================================="
echo " Instalando Zabbix Agent 2 v${ZABBIX_VERSION}"
echo " Proxy: ${PROXY_IP}"
echo " Host: ${HOSTNAME}"
echo "=========================================="

# Repositório oficial Zabbix 7.4 Ubuntu 24.04
wget https://repo.zabbix.com/zabbix/7.4/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.4+ubuntu24.04_all.deb
dpkg -i zabbix-release_latest_7.4+ubuntu24.04_all.deb
apt update -qq
apt install -y zabbix-agent2

cat > /etc/zabbix/zabbix_agent2.conf <<CONF
PidFile=/run/zabbix/zabbix_agent2.pid
LogFile=/var/log/zabbix/zabbix_agent2.log
LogFileSize=0
Server=${PROXY_IP}
ServerActive=${PROXY_IP}
Hostname=${HOSTNAME}
Include=/etc/zabbix/zabbix_agent2.d/*.conf
ControlSocket=/tmp/agent.sock
CONF

systemctl enable zabbix-agent2
systemctl restart zabbix-agent2

echo ""
echo "=========================================="
systemctl is-active zabbix-agent2 && echo " ✅ Agent2 instalado com sucesso!" || echo " ❌ Erro ao iniciar!"
echo " Proxy: ${PROXY_IP}"
echo " Hostname: ${HOSTNAME}"
echo "=========================================="

rm -f zabbix-release_latest*.deb
