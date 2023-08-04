# Api Server
Execute esse script e terá um servidor Docker pronto para a criação de containers e desenvolvimento.
Simples assim :).

O que esse script faz?
- Atualiza o sistema
- Cria um usuario adicional para não usar o usuário root
- Instala o Docker
- Instala o Portainer (Gerenciador web de Containers)
- Instala o NVM
- Instala o NodeJS
- Instala o Nodemon
- Instala o PM2


Simplesmente execute esse comando abaixo:
```sh
$ curl -k -o servidor.sh https://raw.githubusercontent.com/i9suaradio/apiserver/main/servidor.sh && bash servidor.sh && rm -rf servidor.sh
```
License
----
MIT
