#!/bin/bash

# Modelo 2 instalacion

# Rutas del software
install_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
service_location="/usr/lib/systemd/system/"
service_name="ssp.service"
allowed_services="/etc/ssp/permitted_services.txt"

# Instalacion de fichero ejecutable

sudo mkdir "/usr/local/sbin/ssp_"
sudo mv "$install_dir/ssp_/ssp.sh" "/usr/local/sbin/ssp"