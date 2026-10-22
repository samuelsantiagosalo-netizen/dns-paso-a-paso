
#!/bin/bash
set -ex

# Instalar el servidor DNS de los 3 repositorios oficiales
apt-get update
apt-get install -y bind9 bind9utils bind9-doc

# Copiar configuración de IPv4 y reiniciar el servicio
cp /vagrant/config/named /etc/default/named
systemctl restart named