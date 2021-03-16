# Guía de instalación y uso de Docker

## Ubuntu

### docker

Instalar paquetes necesarios

```sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common```

Descargar key

```curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -```

Añadir repositorio

```
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
```

Instalar docker

```
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io (420mb)
```

Para no ejecutarlo como root

```
sudo usermod -aG docker [USUARIO]
newgrp docker
```

### docker-compose

Descargar docker-compose

```sudo curl -L "https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose```

Permisos del binario

```sudo chmod +x /usr/local/bin/docker-compose```

---

## Windows

Descargar docker desktop, ya tiene docker-compose incluido.

https://hub.docker.com/editions/community/docker-ce-desktop-windows

---

## Comandos de interés

Levantar un entorno

```docker-compose up```

- Nota: En windows va a solicitar acceso a las carpetas en el caso de que tenga volúmenes compartidos.

Listar todos los contenedores

```docker ps```

Detener un container

```docker container stop [ID]```

Eliminar un container

```docker container rm [ID]```

Listar imágenes

```docker images```

Eliminar una imagen

```docker image rmi [ID]```

---

## Links de interés

* Instalación de docker en Ubuntu -> https://docs.docker.com/engine/install/ubuntu/
* Instalación de docker-compose en Ubuntu -> https://docs.docker.com/compose/install/
* Instalación de docker en Windows -> https://hub.docker.com/editions/community/docker-ce-desktop-windows
