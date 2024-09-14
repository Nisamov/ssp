#!/bin/bash

# Apache 2.0 License License 2024 Andres Rulsan Abadias Otal

# Script de desinstalacion de servicio

# Rutas del software
service_location="/usr/lib/systemd/system/"
etc_content="/etc/ssp"
sbin_content="/usr/local/sbin/"

sudo systemctl stop ssp.service # Detener el servicio
sudo systemctl disable ssp.service # Deshabilitar el servicio
sudo rm -f "$service_location/ssp.service" # Borrar servicio
sudo rm -rf "$etc_content" # Eliminar contenido de ruta /etc/ssp
sudo rm -f "$sbin_content/ssp" # Eliminar fichero /usr/local/sbin/ssp
sudo rm -rf "$sbin_content/ssp_" # Eliminar contenido de ruta /usr/local/sbin/ssp_

unset service_location # Libera la variable después de usarla
unset etc_content # Libera la variable después de usarla
unset sbin_content # Libera la variable después de usarla

echo "Uninstallation complete."
exit 1