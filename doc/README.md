# DNS Practice: Server Configuration

## 1. Version Control and Documentation
I cloned the repository `dns-paso-a-paso` to my local VS Code environment. To keep the repository clean, I created a `.gitignore` file to ignore the Vagrant virtual machine directory. I also organized the project into folders:

```bash
echo ".vagrant/" > .gitignore
mkdir doc config files
```

## 2. Infrastructure as Code
I prepared the automatic deployment by creating the `Vagrantfile`. This configures the Debian virtual machine, assigns the private IP `192.168.56.10`, and links the provision script `config/bootstrap.sh`.

```ruby
Vagrant.configure("2") do |config|
  config.vm.box = "debian/bookworm64" 
  
  config.vm.define "server" do |srv|
    srv.vm.hostname = "debian"
    srv.vm.network "private_network", ip: "192.168.56.10"
    srv.vm.provision "shell", path: "config/bootstrap.sh"
  end
end
```

## 3. DNS Server Installation
To install the DNS server from the official repositories, I added the required packages to the `config/bootstrap.sh` script.

```bash
#!/bin/bash
set -ex

# Install the DNS server
apt-get update
apt-get install -y bind9 bind9utils bind9-doc dnsutils
```

## 4. Server Configuration
Because we only use IPv4, I copied the `/etc/default/named` file and modified it to include the `-4` parameter.

```text
# run resolvconf?
RESOLVCONF=no

# startup options for the server
OPTIONS="-u bind -4"
```

### 4.1. named.conf.options Configuration
I edited the `named.conf.options` file to define the Access Control List (`acl confiables`) for our network `192.168.56.0/24`. I also configured it to listen on IP `192.168.56.10` and disabled IPv6:

```text
acl confiables {
    127.0.0.1;
    192.168.56.0/24;
};

options {
    directory "/var/cache/bind";
    allow-transfer { none; };
    listen-on port 53 { 127.0.0.1; 192.168.56.10; };
    recursion yes;
    allow-recursion { confiables; };
    dnssec-validation yes;
};
```

### 4.2. named.conf.local Configuration
In this file, I declared the master zones (forward and reverse) for the domain `samuel.test`. I added the IP of the secondary server in the `allow-transfer` block to permit zone copies later.

```text
zone "samuel.test" {
    type master;
    file "/var/lib/bind/samuel.test.dns";
    allow-transfer { 192.168.56.11; };
};

zone "56.168.192.in-addr.arpa" {
    type master;
    file "/var/lib/bind/samuel.test.rev";
    allow-transfer { 192.168.56.11; };
};
```

### 4.3. Forward Zone Creation
I created the forward zone file in `files/samuel.test.dns` with the SOA, NS, and A records.

```text
$TTL    86400
@       IN      SOA     debian.samuel.test. admin.samuel.test. (
                              3          ; Serial
                              3600       ; Refresh
                              1800       ; Retry
                              604800     ; Expire
                              86400 )    ; Negative Cache TTL
;
@       IN      NS      debian.samuel.test.
debian.samuel.test. IN  A       192.168.56.10
```

### 4.4. Reverse Zone Creation
I created the reverse zone file in `files/samuel.test.rev` with the PTR record to translate IPs back to names.

```text
$TTL    86400
@       IN      SOA     debian.samuel.test. admin.samuel.test. (
                              1          ; Serial
                              3600       ; Refresh
                              1800       ; Retry
                              604800     ; Expire
                              86400 )    ; Negative Cache TTL
;
@       IN      NS      debian.samuel.test.
10      IN      PTR     debian.samuel.test.
```

### 4.5. Syntax Checking
I automated the file copying and syntax checking in `config/bootstrap.sh`. The service is restarted to apply all changes automatically.

```bash
named-checkconf
named-checkzone samuel.test /var/lib/bind/samuel.test.dns
named-checkzone 56.168.192.in-addr.arpa /var/lib/bind/samuel.test.rev
systemctl restart named
```

## 5. & 6. Resolution Check (dig & nslookup)
I performed queries to check if the DNS server was answering properly:

```bash
vagrant@debian:~$ dig @192.168.56.10 debian.samuel.test +short
192.168.56.10
```

```bash
vagrant@debian:~$ nslookup debian.samuel.test 192.168.56.10
Server:         192.168.56.10
Address:        192.168.56.10#53

Name:   debian.samuel.test
Address: 192.168.56.10
```

## 7. Extensions
### 7.1. New Records (CNAME and TXT)
I added an alias (CNAME) and a text record (TXT) at the end of the `samuel.test.dns` file to provide more information about the domain:

```text
web                 IN  CNAME   debian.samuel.test.
@                   IN  TXT     "Samuel Santiago Estevez"
```

### 7.2. Auto-test Script
I created a `test.sh` script to verify syntax and resolutions automatically:

```bash
#!/usr/bin/env bash
echo "=== 1. Syntax Check ==="
named-checkconf /etc/bind/named.conf.options && echo "[OK] named.conf.options"
named-checkzone samuel.test /var/lib/bind/samuel.test.dns && echo "[OK] Forward zone"
named-checkzone 56.168.192.in-addr.arpa /var/lib/bind/samuel.test.rev && echo "[OK] Reverse zone"

echo "=== 2. Resolution Check ==="
dig -4 @127.0.0.1 web.samuel.test CNAME +short
dig -4 @127.0.0.1 samuel.test TXT +short
dig -4 @127.0.0.1 -x 192.168.56.10 +short
```

## 8. Secondary Server
### 8.1. Adding the Second VM
I added a secondary server to the `Vagrantfile` with the IP `192.168.56.11`.

```ruby
  config.vm.define "secundario" do |sec|
    sec.vm.hostname = "debian2"
    sec.vm.network "private_network", ip: "192.168.56.11"
  end
```

### 8.3 & 8.4 Secondary Configuration
I installed BIND9 on the secondary server and configured `named.conf.options` to listen on its own IP:

```text
listen-on port 53 { 127.0.0.1; 192.168.56.11; };
```

### 8.5 Declaring Slave Zones
In the secondary server's `named.conf.local`, I configured the zones to download as slaves from the primary server (`192.168.56.10`):

```text
zone "samuel.test" {
    type slave;
    masters { 192.168.56.10; };
    file "/var/cache/bind/samuel.test.dns";
};

zone "56.168.192.in-addr.arpa" {
    type slave;
    masters { 192.168.56.10; };
    file "/var/cache/bind/samuel.test.rev";
};
```

### 8.6 Transfer Verification
I restarted the BIND9 service and checked the logs with `sudo journalctl -u named` to confirm the zones were transferred successfully. The logs showed `Transfer status: success` and `Transfer completed`. Finally, I checked the authority of the secondary server:

```bash
vagrant@debian2:~$ dig @192.168.56.11 samuel.test SOA +norecurse +short
debian.samuel.test. admin.samuel.test. 3 3600 1800 604800 86400
```