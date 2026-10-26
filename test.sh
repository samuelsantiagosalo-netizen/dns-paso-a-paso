#!/usr/bin/env bash

echo "=== 1. Comprobación de sintaxis de ficheros ==="
named-checkconf /etc/bind/named.conf.options && echo "[OK] named.conf.options"
named-checkzone samuel.test /var/lib/bind/samuel.test.dns && echo "[OK] Zona directa"
named-checkzone 56.168.192.in-addr.arpa /var/lib/bind/samuel.test.rev && echo "[OK] Zona inversa"

echo "=== 2. Comprobación de resolución ==="
dig -4 @127.0.0.1 web.samuel.test CNAME +short
dig -4 @127.0.0.1 samuel.test TXT +short
dig -4 @127.0.0.1 -x 192.168.56.10 +short