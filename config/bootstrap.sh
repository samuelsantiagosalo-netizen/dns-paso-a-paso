#!/bin/bash
set -ex

# Instalar el servidor DNS de los repositorios oficiales
apt-get update
apt-get install -y bind9 bind9utils bind9-doc dnsutils

# Copiar configuraciones desde la carpeta compartida files/
cp /vagrant/files/named /etc/default/named
cp /vagrant/files/named.conf.options /etc/bind/named.conf.options
cp /vagrant/files/named.conf.local /etc/bind/named.conf.local

# Copiar Ficheros de zona 
cp /vagrant/files/samuel.test.dns /var/lib/bind/samuel.test.dns
cp /vagrant/files/samuel.test.rev /var/lib/bind/samuel.test.rev

# Comprobaciones de sintaxis automáticas 
named-checkconf
named-checkzone samuel.test /var/lib/bind/samuel.test.dns
named-checkzone 56.168.192.in-addr.arpa /var/lib/bind/samuel.test.rev

# Reiniciar el servicio para aplicar todos los cambios
systemctl restart named

# Script de autocomprobación 
chmod +x /vagrant/test.sh
/vagrant/test.sh