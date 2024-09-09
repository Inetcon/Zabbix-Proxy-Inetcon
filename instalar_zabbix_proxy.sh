#!/bin/bash

# Solicitar as variáveis
read -p "Digite a senha de root do banco de dados MariaDB: " DB_ROOT_PASS
read -p "Digite a senha que será utilizada para o usuário Zabbix no banco de dados: " DB_ZABBIX_PASS
read -p "Digite o hostname deste proxy Zabbix: " HOSTNAME

ZABBIX_SERVER_IP='proxy.inetcon.com.br'
ZABBIX_CONF_FILE='/etc/zabbix/zabbix_proxy.conf'

# Baixar o Zabbix Proxy
echo "Baixando Zabbix Proxy..."
wget https://repo.zabbix.com/zabbix/6.0/debian/pool/main/z/zabbix-release/zabbix-release_6.0-5+debian$(cut -d"." -f1 /etc/debian_version)_all.deb

# Descompactar e instalar o Zabbix Release
echo "Instalando Zabbix Release..."
dpkg -i zabbix-release_6.0-5+debian$(cut -d"." -f1 /etc/debian_version)_all.deb

# Atualizar os repositórios
echo "Atualizando os repositórios..."
apt update

# Instalar os pacotes necessários (Zabbix Proxy, SQL Scripts, Agent, MariaDB)
echo "Instalando pacotes Zabbix Proxy e MariaDB..."
apt -y install zabbix-proxy-mysql zabbix-sql-scripts zabbix-agent mariadb-server

# Iniciar e habilitar o MariaDB
echo "Iniciando e habilitando o MariaDB..."
systemctl start mariadb
systemctl enable mariadb

# Criar Database para o Proxy Zabbix
echo "Configurando banco de dados para o Zabbix Proxy..."
mysql -uroot -p"$DB_ROOT_PASS" -e "create database zabbix_proxy character set utf8mb4 collate utf8mb4_bin;"
mysql -uroot -p"$DB_ROOT_PASS" -e "grant all privileges on zabbix_proxy.* to zabbix@localhost identified by '$DB_ZABBIX_PASS';"

# Importar template do banco de dados para o Zabbix Proxy
echo "Importando tabelas para o banco de dados Zabbix Proxy... (isso pode demorar)"
cat /usr/share/zabbix-sql-scripts/mysql/proxy.sql | mysql --default-character-set=utf8mb4 -uzabbix -p"$DB_ZABBIX_PASS" zabbix_proxy

# Editar o arquivo de configuração do Zabbix Proxy
echo "Configurando arquivo zabbix_proxy.conf..."
sed -i "s/^Server=.*/Server=$ZABBIX_SERVER_IP/" $ZABBIX_CONF_FILE
sed -i "s/^Hostname=.*/Hostname=$HOSTNAME/" $ZABBIX_CONF_FILE
sed -i "s/^# EnableRemoteCommands=0/EnableRemoteCommands=1/" $ZABBIX_CONF_FILE
sed -i "s/^# DBPassword=/DBPassword=$DB_ZABBIX_PASS/" $ZABBIX_CONF_FILE

# Adicionar parâmetros adicionais no arquivo de configuração
echo "Adicionando parâmetros extras ao arquivo de configuração..."
cat <<EOL >> $ZABBIX_CONF_FILE
ProxyOfflineBuffer=24
ConfigFrequency=120
DataSenderFrequency=120
StartPollers=5
StartPreprocessors=10
StartPingers=4
StartDiscoverers=10
StartHTTPPollers=5
StartVMwareCollectors=4
VMwareFrequency=60
VMwarePerfFrequency=60
VMwareCacheSize=500M
CacheSize=2G
Timeout=10
EOL

# Reiniciar e habilitar o Zabbix Proxy
echo "Reiniciando e habilitando o Zabbix Proxy..."
systemctl restart zabbix-proxy
systemctl enable zabbix-proxy

echo "Instalação e configuração do Zabbix Proxy concluída com sucesso!"
