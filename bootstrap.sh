
#!/bin/bash
set -ex

# Instalar el servidor DNS de los 3 repositorios oficiales
apt-get update
apt-get install -y bind9 bind9utils bind9-doc

# Copiar configuración de IPv4 
cp /vagrant/config/named /etc/default/named
systemctl restart named

# Configuración de opciones en named.conf.options
cp /etc/bind/named.conf.options /etc/bind/named.conf.options.backup
cp /vagrant/config/named.conf.options /etc/bind/named.conf.options

# Reiniciar el servicio para aplicar todos los cambios
systemctl restart named