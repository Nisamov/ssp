#!/bin/bash

# Modelo 2 instalacion

# Rutas del software
install_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
service_location="/usr/lib/systemd/system/"
service_name="ssp.service"
allowed_services="/etc/ssp/permitted_services.txt"
install_dir_sbin="/usr/local/sbin"

# Instalacion de fichero ejecutable

