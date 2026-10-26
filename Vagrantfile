# -*- mode: ruby -*
# vi: set ft=ruby :
Vagrant.configure("2") do |config|
  # Descarga la iso de debian
  config.vm.box = "debian/bookworm64" 
  
  #Máquina 1
  config.vm.define "server" do |srv|
    # Ese sera el nombre de la vm
    srv.vm.hostname = "debian"
    
    # Crea una red privada de solo anfitrion y le da una IP estatica
    srv.vm.network "private_network", ip: "192.168.56.10"
    
    # Ejecuta el script bootstrap.sh que hace se haga la instalación automatica al arrancar por primera vez
    srv.vm.provision "shell", path: "config/bootstrap.sh"
  end
  # Máquina 2: Servidor Secundario 
  config.vm.define "secundario" do |sec|
    sec.vm.hostname = "debian2"
    sec.vm.network "private_network", ip: "192.168.56.11"
  end
  
end