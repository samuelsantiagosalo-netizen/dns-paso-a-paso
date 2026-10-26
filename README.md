# dns-paso-a-paso
Samuel Santiago Estevez

# DNS Server Configuration

This repository contains a complete, step-by-step configuration of a DNS server using **BIND9** on **Debian**. The environment is fully automated using **Vagrant** and provisioned with a Bash script.

## Features
 **Infrastructure as Code (IaC):** Virtual machines are managed and deployed with Vagrant.
 **Primary DNS Server:** Authoritative for the `samuel.test` domain.
 **Secondary DNS Server:** Automated zone transfers from the primary server.
 **Automated Testing:** Includes a `test.sh` script to verify syntax and DNS resolution.

## Repository Structure
 `Vagrantfile`: Defines the primary (`192.168.56.10`) and secondary (`192.168.56.11`) servers.
 `config/bootstrap.sh`: Automates the installation and configuration of the primary server.
 `files/`: Contains all the BIND9 configuration files and DNS zones.
 `test.sh`: Script to automatically test syntax and DNS records.
`doc/`: Contains the detailed step-by-step documentation of the project.

Read the full documentation in the README file.