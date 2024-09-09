Após formatar o Servidor, acessar ele por SSH e rodar os seguintes comandos

### Entrar em modo Root

su - 

### Instalar o GIT

apt install git

### Importar o arquivo de configuração do proxy

git clone https://github.com/Inetcon/Zabbix-Proxy-Inetcon.git

### Acessar o Diretório

cd Zabbix-Proxy-Inetcon/

### Executar o Script (Ele vai solicitar 3 Informações, senha para o Root do banco de dados, senha para o usuário zabbix no banco de dados e nome do proxy que será cadastrado no zabbix server)

bash instalar_zabbix_proxy.sh


### Após isso o proxy estará instalado, vai faltar somente acessar o zabbix e cadastrar o proxy no servidor
