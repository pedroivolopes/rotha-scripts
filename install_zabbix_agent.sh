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
OS_CODENAME=$(lsb_release -sc)

echo "=========================================="
echo " Instalando Zabbix Agent 2 v${ZABBIX_VERSION}"
echo " Proxy: ${PROXY_IP}"
echo " Host: ${HOSTNAME}"
echo "=========================================="

# 1. Adiciona repositório
wget -q https://repo.zabbix.com/zabbix/${ZABBIX_VERSION}/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_${ZABBIX_VERSION}+ubuntu${OS_CODENAME}_all.deb 2>/dev/null || \
wget -q https://repo.zabbix.com/zabbix/${ZABBIX_VERSION}/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest+ubuntu${OS_CODENAME}_all.deb

dpkg -i zabbix-release_latest*.deb
apt update -qq

# 2. Instala o agent2
apt install -y zabbix-agent2

# 3. Configura apontando pro proxy
cat > /etc/zabbix/zabbix_agent2.conf <<EOF
PidFile=/run/zabbix/zabbix_agent2.pid
LogFile=/var/log/zabbix/zabbix_agent2.log
LogFileSize=0
Server=${PROXY_IP}
ServerActive=${PROXY_IP}
Hostname=${HOSTNAME}
Include=/etc/zabbix/zabbix_agent2.d/*.conf
ControlSocket=/tmp/agent.sock
EOF

# 4. Habilita e inicia
systemctl enable zabbix-agent2
systemctl restart zabbix-agent2

# 5. Verifica status
echo ""
echo "=========================================="
systemctl is-active zabbix-agent2 && echo " Agent2 rodando com sucesso!" || echo " Erro ao iniciar o agent!"
echo " Proxy: ${PROXY_IP}"
echo " Hostname: ${HOSTNAME}"
echo "=========================================="

# Limpa arquivo de instalação
rm -f zabbix-release_latest*.deb