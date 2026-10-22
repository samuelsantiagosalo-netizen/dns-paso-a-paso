# Práctica DNS: Configuración de un servidor

## 1 Control de versiones y Documentación
Se ha clonado el repositorio `dns-paso-a-paso` en mi entorno local en vscode. Para mantener el repositorio limpio, se ha creado el fichero `.gitignore` para ignorar el directorio de la máquina virtual, además de los directorios `doc/` y `config/`.

```bash
echo "vagrant/" > .gitignore
mkdir doc config
```

## 2 Infraestructura como código
Se ha preparado el despliegue automático creando el fichero `Vagrantfile` con la configuración de la máquina virtual del servidor Debian, asignándole la dirección IP privada `192.168.56.10` y enlazando el script de provisión `bootstrap.sh`.

```# -*- mode: ruby -*
   # vi: set ft=ruby :
    Vagrant.configure("2") do |config|
    # Descarga la iso de debian
    config.vm.box = "debian/bookworm64" 
    
    config.vm.define "server" do |srv|
        # Ese sera el nombre de la vm
        srv.vm.hostname = "debian"
        
        # Crea una red privada de solo anfitrion y le da una IP estatica
        srv.vm.network "private_network", ip: "192.168.56.10"
        
        # Ejecuta el script bootstrap.sh que hace se haga la instalación automatica al arrancar por primera vez
        srv.vm.provision "shell", path: "bootstrap.sh"
    end
    end
```

## 3. Instalación de servidor DNS
Para instalar el servidor DNS desde los repositorios oficiales, hemos añadido los paquetes necesarios (`bind9`, `bind9utils` y `bind9-doc`) al fichero de provisión `bootstrap.sh`.

```bash
#!/bin/bash
set -ex

# Instalar el servidor DNS de los 3 repositorios oficiales
apt-get update
apt-get install -y bind9 bind9utils bind9-doc
```

Una vez levantada la máquina con `vagrant up` y accediendo mediante `vagrant ssh server`, comprobamos que el servicio se encuentra activo:

```bash
vagrant@debian:~$ systemctl status named
● named.service - BIND Domain Name Server
     Loaded: loaded (/lib/systemd/system/named.service; enabled; preset: enabled)
     Active: active (running)
```

## 4. Configuración del servidor 
Puesto que en clase sólo vamos a utilizar IPv4, copiamos el archivo `/etc/default/named` de la máquina virtual a nuestra carpeta compartida `/vagrant/config/` para modificarlo.

```bash
vagrant@debian:~$ sudo cp /etc/default/named /vagrant/config/named
```

Modificamos el fichero `config/named` para añadir el parámetro `-4`:

```text
# run resolvconf?
RESOLVCONF=no

# startup options for the server
OPTIONS="-u bind -4"
```

Por último, añadimos en `bootstrap.sh` los comandos para copiar este archivo dentro de la máquina virtual y reiniciar el servicio automáticamente:

```bash
cp /vagrant/config/named /etc/default/named
systemctl restart named
```
