#!/bin/bash

# Modelo 2 instalacion

# Rutas del software
install_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
service_location="/usr/lib/systemd/system/"
service_name="ssp.service"
allowed_services="/etc/ssp/permitted_services.txt"
install_dir_sbin="/usr/local/sbin"

# Instalacion de fichero ejecutable

# Ruta /user/local/sbin/

# Creacion de /usr/local/sbin/ssp/ como directorio
sudo mkdir "$install_dir_bin/ssp"
echo "$install_dir_bin/ssp"

if [[ -d "$install_dir_bin/ssp" ]]; then
    echo "ok Dir"
fi

# Clonacion de fichero ssp.sh
cp "$install_dir/ssp_/ssp.sh" "$install_dir_bin/ssp"

if [[ -f "$install_dir_bin/ssp" ]]; then
    echo "ok File"
fi