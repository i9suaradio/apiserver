#!/bin/bash +x

## Funcoes
promptsn() {
  while true; do
    read -p "$1 " sn
    case $sn in
    [YySs]*) return 0 ;;
    [Nn]*) return 1 ;;
    *) echo -e "\e[0mResponda apenas com (S)SIM ou (N)Não" ;;
    esac
  done
}

reset_cor() {
  echo -e "\e[0m"
}

cor() {
  case $1 in
  "red") echo -e "\e[1m\e[31m" ;;
  "green") echo -e "\e[1m\e[32m" ;;
  "blue") echo -e "\e[1m\e[96m" ;;
  "yellow") echo -e "\e[1m\e[33m" ;;
  *) echo -e "\e[0m" ;;
  esac
}
## Funcoes

############################
echo -e "\e[1m\e[92m----------------------------------"
echo -e "\e[1m\e[92m---------Api Server 1.0-----------"
echo -e "\e[1m\e[92m----------------------------------"
reset_cor

echo -e "\e[1m\e[92m----------------------------------"
echo -e "\e[1m\e[92mAtualização inicial do sistema ..."
echo -e "\e[1m\e[92m----------------------------------"
reset_cor
sudo yum -y update && sudo yum -y upgrade
yum check-update
yum -y install htop nano ufw wget nethogs unar certbot unzip

############################

echo -e "\e[1m\e[92m--------------------------"
echo -e "\e[1m\e[92mConfigurando Firewall..."
echo -e "\e[1m\e[92m--------------------------"
reset_cor

if promptsn "Liberar as portas padrão no firewall?"; then
  echo -e "\e[1m\e[92mDigite o range que deseja liberar no firewall (Ex.: 3000 ou 3000-5000)... \e[0m"
  read range
  sudo firewall-cmd --add-service=http
  sudo firewall-cmd --add-service=https
  sudo firewall-cmd --zone=public --add-port=$range/tcp --permanent
  sudo firewall-cmd --runtime-to-permanent
  sudo firewall-cmd --reload
else
  echo "Ok, próxima tarefa..."
  reset_cor
fi

############################

echo -e "\e[1m\e[92m--------------------------"
echo -e "\e[1m\e[92mCriando Usuario Inicial..."
echo -e "\e[1m\e[92m--------------------------"
reset_cor

if promptsn "Deseja criar um novo usuário"; then
  echo -e "\e[1m\e[92mDigite o nome do usuario... \e[0m"
  read novousuario
  if id $novousuario >/dev/null 2>&1; then
    echo -e "\e[1m\e[31mO usuario $novousuario já existe..."
  else
    echo -e "\e[1m\e[92mCriando o usuario: $novousuario..."
    $(adduser $novousuario)

    echo -e "\e[1m\e[92mDefinindo a senha do usuario: $novousuario..."
    $(passwd $novousuario)
  fi
else
  echo "Ok, próxima tarefa..."
  reset_cor
fi

############################

echo -e "\e[1m\e[92m----------------------"
echo -e "\e[1m\e[92mInstalando Docker..."
echo -e "\e[1m\e[92m----------------------"
reset_cor

if promptsn "Deseja instalar o Docker? "; then
  curl -fsSL https://get.docker.com/ | sh
  sudo systemctl start docker

  echo -e "\e[1m\e[92mDocker Version"
  reset_cor
  docker version

  sudo systemctl enable docker

  if promptsn "Deseja executar o Docker sem o comando 'sudo'?"; then
    sudo usermod -aG docker $(whoami)
  fi

  if promptsn "Deseja instalar o docker-compose??"; then
    sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
  fi

  if promptsn "Deseja instalar o gerenciador de containers Portainer?"; then
    docker volume create portainer_data
    docker run -d -p 8000:8000 -p 9000:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce
    docker ps
  fi

  if promptsn "Criar volume com de nome Storage?"; then
    docker volume create --driver local --opt type=none --opt device=/home/$novousuario/www --opt o=bind storage
  fi

fi

############################

echo -e "\e[1m\e[92m----------------------"
echo -e "\e[1m\e[92mInstalando NVM"
echo -e "\e[1m\e[92m----------------------"
reset_cor

if promptsn "Deseja instalar o NVM - Node Version Manager? "; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
  export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")" [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
  source ~/.bash_profile
  echo -e "\e[1m\e[92mNVM Version"
  nvm --version

  echo -e "\e[1m\e[92m----------------------"
  echo -e "\e[1m\e[92mInstalando Node"
  echo -e "\e[1m\e[92m----------------------"
  reset_cor

  if promptsn "Deseja instalar o NodeJS? "; then
    nvm install node --lts
    echo -e "\e[1m\e[92mNode Version"
    reset_cor
    node -v

    echo -e "\e[1m\e[92mNPM Version"
    reset_cor
    npm -v

    if promptsn "Deseja instalar o NODEMON? "; then
      echo -e "\e[1m\e[92mInstalando NODEMON..."
      npm install -g nodemon

      echo -e "\e[1m\e[92mNode Version"
      nodemon -v
      reset_cor
    fi

    if promptsn "Deseja instalar o PM2? "; then
      echo -e "\e[1m\e[92mInstalando PM2..."
      npm install -g pm2

      pm2 startup systemd
      pm2 save

      echo -e "\e[1m\e[92mNode Version"
      pm2 --version
      reset_cor
    fi
  fi

fi

#Execucoes finais
sudo systemctl enable --now certbot-renew.timer

echo -e "\e[1m\e[92m-------------------------------"
echo -e "\e[1m\e[92mScript executado com sucesso..."
echo -e "\e[1m\e[92m-------------------------------"
reset_cor
echo -e "Adicione manualmente a linha abaixo:"
echo -e "\e[1m\e[92mrenew_hook = systemctl reload rabbitmq"
reset_cor
echo -e "No arquivo: /etc/letsencrypt/renewal/example.com.conf"

#Reset da cor
reset_cor

echo -e "\e[1m\e[92m------------------------------------------------------------"
echo -e "\e[1m\e[92mReiniciar o servidor para atualizar algumas configurações..."
echo -e "\e[1m\e[92m------------------------------------------------------------"

if promptsn "Deseja reiniciar o servidor? "; then
  reboot
fi

#Reset da cor
reset_cor